import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '/core/errors/failures.dart';
import '/core/utils/constants.dart';
import '/domain/usecases/get_forecast.dart';
import '/presentation/blocs/forecast/forecast_state.dart';
import '../../../core/errors/exceptions.dart';

class ForecastCubit extends Cubit<ForecastState> {
  final GetForecast getForecast;

  ForecastCubit({required this.getForecast}) : super(const ForecastState());

  Future<void> fetchForecastByCity(String city) async {
    if (state.isLoading && !state.isRefreshing) return;

    emit(
      state.copyWith(
        status: ForecastStatus.loading,
        cityName: city,
        isRefreshing: state.isSuccess,
      ),
    );

    final result = await getForecast(Params.byCity(city));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ForecastStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
          isRefreshing: false,
        ),
      ),
      (forecast) => emit(
        state.copyWith(
          status: ForecastStatus.success,
          forecast: forecast,
          errorMessage: null,
          isRefreshing: false,
        ),
      ),
    );
  }

  Future<void> fetchForecastByCurrentLocation() async {
    if (state.isLoading && !state.isRefreshing) return;

    emit(
      state.copyWith(
        status: ForecastStatus.loading,
        cityName: 'Current Location',
        isRefreshing: state.isSuccess,
      ),
    );

    try {
      final position = await _determinePosition();
      final result = await getForecast(
        Params.byCoordinates(position.latitude, position.longitude),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: ForecastStatus.failure,
            errorMessage: _mapFailureToMessage(failure),
            isRefreshing: false,
          ),
        ),
        (forecast) => emit(
          state.copyWith(
            status: ForecastStatus.success,
            forecast: forecast,
            errorMessage: null,
            cityName: forecast.cityName,
            isRefreshing: false,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForecastStatus.failure,
          errorMessage: e.toString(),
          isRefreshing: false,
        ),
      );
    }
  }

  Future<void> fetchForecastByDefault() async {
    await fetchForecastByCity(AppConstants.defaultCity);
  }

  Future<void> refreshForecast() async {
    if (state.cityName == null) {
      await fetchForecastByDefault();
      return;
    }

    if (state.cityName == 'Current Location') {
      await fetchForecastByCurrentLocation();
      return;
    }

    await fetchForecastByCity(state.cityName!);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Network error. Please check your internet connection.';
      case CacheFailure:
        return 'Cache error. No saved data available.';
      case LocationFailure:
        return 'Location error. Please enable location services and try again.';
      default:
        return 'Unexpected error occurred. Please try again.';
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        message:
            'Location services are disabled. Please enable them in settings.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
          message:
              'Location permissions are denied. Please enable them in settings.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        message:
            'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}

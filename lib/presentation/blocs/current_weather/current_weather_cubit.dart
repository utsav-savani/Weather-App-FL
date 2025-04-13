import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '/core/errors/failures.dart';
import '/core/utils/constants.dart';
import '/domain/usecases/get_current_weather.dart';
import '/presentation/blocs/current_weather/current_weather_state.dart';
import '../../../core/errors/exceptions.dart';

class CurrentWeatherCubit extends Cubit<CurrentWeatherState> {
  final GetCurrentWeather getCurrentWeather;

  CurrentWeatherCubit({required this.getCurrentWeather})
    : super(const CurrentWeatherState());

  Future<void> fetchWeatherByCity(String city) async {
    if (state.isLoading && !state.isRefreshing) return;

    emit(
      state.copyWith(
        status: CurrentWeatherStatus.loading,
        cityName: city,
        isRefreshing: state.isSuccess,
      ),
    );

    final result = await getCurrentWeather(Params.byCity(city));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CurrentWeatherStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
          isRefreshing: false,
        ),
      ),
      (weather) => emit(
        state.copyWith(
          status: CurrentWeatherStatus.success,
          weather: weather,
          errorMessage: null,
          isRefreshing: false,
        ),
      ),
    );
  }

  Future<void> fetchWeatherByCurrentLocation() async {
    if (state.isLoading && !state.isRefreshing) return;

    emit(
      state.copyWith(
        status: CurrentWeatherStatus.loading,
        cityName: 'Current Location',
        isRefreshing: state.isSuccess,
      ),
    );

    try {
      final position = await _determinePosition();
      final result = await getCurrentWeather(
        Params.byCoordinates(position.latitude, position.longitude),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: CurrentWeatherStatus.failure,
            errorMessage: _mapFailureToMessage(failure),
            isRefreshing: false,
          ),
        ),
        (weather) => emit(
          state.copyWith(
            status: CurrentWeatherStatus.success,
            weather: weather,
            errorMessage: null,
            cityName: weather.cityName,
            isRefreshing: false,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CurrentWeatherStatus.failure,
          errorMessage: e.toString(),
          isRefreshing: false,
        ),
      );
    }
  }

  Future<void> fetchWeatherByDefault() async {
    await fetchWeatherByCity(AppConstants.defaultCity);
  }

  Future<void> refreshWeather() async {
    if (state.cityName == null) {
      await fetchWeatherByDefault();
      return;
    }

    if (state.cityName == 'Current Location') {
      await fetchWeatherByCurrentLocation();
      return;
    }

    await fetchWeatherByCity(state.cityName!);
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

    // Test if location services are enabled.
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

import 'package:assessmentfounder/core/errors/failures.dart';
import 'package:assessmentfounder/core/utils/constants.dart';
import 'package:assessmentfounder/domain/entities/current_weather.dart';
import 'package:assessmentfounder/domain/usecases/get_current_weather.dart';
import 'package:assessmentfounder/presentation/blocs/current_weather/current_weather_cubit.dart';
import 'package:assessmentfounder/presentation/blocs/current_weather/current_weather_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'current_weather_cubit_test.mocks.dart';

@GenerateMocks([GetCurrentWeather])
void main() {
  late CurrentWeatherCubit cubit;
  late MockGetCurrentWeather mockGetCurrentWeather;

  setUp(() {
    mockGetCurrentWeather = MockGetCurrentWeather();
    cubit = CurrentWeatherCubit(getCurrentWeather: mockGetCurrentWeather);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be CurrentWeatherState.initial', () {
    expect(cubit.state, const CurrentWeatherState());
    expect(cubit.state.status, CurrentWeatherStatus.initial);
  });

  group('fetchWeatherByCity', () {
    const tCity = 'London';
    final now = DateTime.now();
    final tCurrentWeather = CurrentWeather(
      cityName: 'London',
      country: 'GB',
      temperature: 15.5,
      feelsLike: 14.8,
      tempMin: 13.2,
      tempMax: 17.3,
      pressure: 1012,
      humidity: 76,
      visibility: 10000,
      weatherMain: 'Clear',
      weatherDescription: 'clear sky',
      weatherIcon: '01d',
      windSpeed: 3.6,
      windDeg: 320,
      timestamp: now,
      sunrise: now.subtract(const Duration(hours: 6)),
      sunset: now.add(const Duration(hours: 6)),
    );

    blocTest<CurrentWeatherCubit, CurrentWeatherState>(
      'emits [loading, success] when fetching weather succeeds',
      build: () {
        when(
          mockGetCurrentWeather(any),
        ).thenAnswer((_) async => Right(tCurrentWeather));
        return cubit;
      },
      act: (cubit) => cubit.fetchWeatherByCity(tCity),
      expect:
          () => [
            const CurrentWeatherState(
              status: CurrentWeatherStatus.loading,
              cityName: 'London',
              isRefreshing: false,
            ),
            CurrentWeatherState(
              status: CurrentWeatherStatus.success,
              weather: tCurrentWeather,
              cityName: 'London',
              isRefreshing: false,
            ),
          ],
      verify: (cubit) {
        verify(mockGetCurrentWeather(Params.byCity(tCity)));
      },
    );

    blocTest<CurrentWeatherCubit, CurrentWeatherState>(
      'emits [loading, failure] when fetching weather fails',
      build: () {
        when(mockGetCurrentWeather(any)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchWeatherByCity(tCity),
      expect:
          () => [
            const CurrentWeatherState(
              status: CurrentWeatherStatus.loading,
              cityName: 'London',
              isRefreshing: false,
            ),
            const CurrentWeatherState(
              status: CurrentWeatherStatus.failure,
              errorMessage: 'Server error',
              cityName: 'London',
              isRefreshing: false,
            ),
          ],
    );
  });

  group('fetchWeatherByDefault', () {
    const tDefaultCity = AppConstants.defaultCity;
    final now = DateTime.now();
    final tCurrentWeather = CurrentWeather(
      cityName: tDefaultCity,
      country: 'GB',
      temperature: 15.5,
      feelsLike: 14.8,
      tempMin: 13.2,
      tempMax: 17.3,
      pressure: 1012,
      humidity: 76,
      visibility: 10000,
      weatherMain: 'Clear',
      weatherDescription: 'clear sky',
      weatherIcon: '01d',
      windSpeed: 3.6,
      windDeg: 320,
      timestamp: now,
      sunrise: now.subtract(const Duration(hours: 6)),
      sunset: now.add(const Duration(hours: 6)),
    );

    blocTest<CurrentWeatherCubit, CurrentWeatherState>(
      'emits [loading, success] when fetching default weather succeeds',
      build: () {
        when(
          mockGetCurrentWeather(any),
        ).thenAnswer((_) async => Right(tCurrentWeather));
        return cubit;
      },
      act: (cubit) => cubit.fetchWeatherByDefault(),
      expect:
          () => [
            const CurrentWeatherState(
              status: CurrentWeatherStatus.loading,
              cityName: tDefaultCity,
              isRefreshing: false,
            ),
            CurrentWeatherState(
              status: CurrentWeatherStatus.success,
              weather: tCurrentWeather,
              cityName: tDefaultCity,
              isRefreshing: false,
            ),
          ],
      verify: (cubit) {
        verify(mockGetCurrentWeather(Params.byCity(tDefaultCity)));
      },
    );
  });

  group('fetchWeatherByCurrentLocation', () {
    final now = DateTime.now();
    final tCurrentWeather = CurrentWeather(
      cityName: 'Current City',
      country: 'CC',
      temperature: 15.5,
      feelsLike: 14.8,
      tempMin: 13.2,
      tempMax: 17.3,
      pressure: 1012,
      humidity: 76,
      visibility: 10000,
      weatherMain: 'Clear',
      weatherDescription: 'clear sky',
      weatherIcon: '01d',
      windSpeed: 3.6,
      windDeg: 320,
      timestamp: now,
      sunrise: now.subtract(const Duration(hours: 6)),
      sunset: now.add(const Duration(hours: 6)),
    );

    blocTest<CurrentWeatherCubit, CurrentWeatherState>(
      'emits [loading, failure] when location access fails',
      build: () {
        return cubit;
      },
      act: (cubit) => cubit.fetchWeatherByCurrentLocation(),
      expect:
          () => [
            const CurrentWeatherState(
              status: CurrentWeatherStatus.loading,
              cityName: 'Current Location',
              isRefreshing: false,
            ),
            predicate<CurrentWeatherState>(
              (state) =>
                  state.status == CurrentWeatherStatus.failure &&
                  state.errorMessage != null &&
                  state.isRefreshing == false,
            ),
          ],
    );
  });
}

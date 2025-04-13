import 'package:assessmentfounder/core/errors/exceptions.dart';
import 'package:assessmentfounder/core/errors/failures.dart';
import 'package:assessmentfounder/data/datasources/local/weather_local_data_source.dart';
import 'package:assessmentfounder/data/datasources/remote/weather_remote_data_source.dart';
import 'package:assessmentfounder/data/models/current_weather_model.dart';
import 'package:assessmentfounder/data/repositories/weather_repository_impl.dart';
import 'package:assessmentfounder/domain/entities/current_weather.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'weather_repository_impl_test.mocks.dart';

@GenerateMocks([WeatherRemoteDataSource, WeatherLocalDataSource, Connectivity])
void main() {
  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDataSource mockRemoteDataSource;
  late MockWeatherLocalDataSource mockLocalDataSource;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockRemoteDataSource = MockWeatherRemoteDataSource();
    mockLocalDataSource = MockWeatherLocalDataSource();
    mockConnectivity = MockConnectivity();
    repository = WeatherRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      connectivity: mockConnectivity,
    );
  });

  group('getCurrentWeatherByCity', () {
    const tCity = 'London';
    final now = DateTime.now();
    final tWeatherModel = CurrentWeatherModel(
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

    test('should check if the device is online', () async {
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.wifi);
      when(
        mockRemoteDataSource.getCurrentWeatherByCity(any),
      ).thenAnswer((_) async => tWeatherModel);
      when(
        mockLocalDataSource.cacheCurrentWeather(any, any),
      ).thenAnswer((_) async => {});
      when(
        mockLocalDataSource.addToSearchHistory(any),
      ).thenAnswer((_) async => {});

      await repository.getCurrentWeatherByCity(tCity);

      verify(mockConnectivity.checkConnectivity());
    });

    test('should return remote data when the device is online', () async {
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.wifi);
      when(
        mockRemoteDataSource.getCurrentWeatherByCity(any),
      ).thenAnswer((_) async => tWeatherModel);
      when(
        mockLocalDataSource.cacheCurrentWeather(any, any),
      ).thenAnswer((_) async => {});
      when(
        mockLocalDataSource.addToSearchHistory(any),
      ).thenAnswer((_) async => {});

      final result = await repository.getCurrentWeatherByCity(tCity);

      verify(mockRemoteDataSource.getCurrentWeatherByCity(tCity));
      expect(result, equals(Right<Failure, CurrentWeather>(tWeatherModel)));
    });

    test('should cache the data locally when the device is online', () async {
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.wifi);
      when(
        mockRemoteDataSource.getCurrentWeatherByCity(any),
      ).thenAnswer((_) async => tWeatherModel);
      when(
        mockLocalDataSource.cacheCurrentWeather(any, any),
      ).thenAnswer((_) async => {});
      when(
        mockLocalDataSource.addToSearchHistory(any),
      ).thenAnswer((_) async => {});

      await repository.getCurrentWeatherByCity(tCity);

      verify(mockLocalDataSource.cacheCurrentWeather(tCity, tWeatherModel));
    });

    test('should return cached data when the device is offline', () async {
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.none);
      when(
        mockLocalDataSource.getCachedCurrentWeather(any),
      ).thenAnswer((_) async => tWeatherModel);

      final result = await repository.getCurrentWeatherByCity(tCity);

      verify(mockLocalDataSource.getCachedCurrentWeather(tCity));
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, equals(Right<Failure, CurrentWeather>(tWeatherModel)));
    });

    test(
      'should return CacheFailure when no cached data is present and the device is offline',
      () async {
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.none);
        when(
          mockLocalDataSource.getCachedCurrentWeather(any),
        ).thenThrow(CacheException(message: 'No cached data found'));

        final result = await repository.getCurrentWeatherByCity(tCity);

        verify(mockLocalDataSource.getCachedCurrentWeather(tCity));
        expect(
          result,
          equals(
            const Left<Failure, CurrentWeather>(
              CacheFailure(message: 'No cached data found'),
            ),
          ),
        );
      },
    );

    test(
      'should try fallback cities when the primary city cache fails',
      () async {
        const fallbackCity = 'Paris';
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => ConnectivityResult.none);
        when(
          mockLocalDataSource.getCachedCurrentWeather(tCity),
        ).thenThrow(CacheException(message: 'No cached data found'));
        when(
          mockLocalDataSource.getLastSearchedCities(),
        ).thenAnswer((_) async => [fallbackCity]);
        when(
          mockLocalDataSource.getCachedCurrentWeather(fallbackCity),
        ).thenAnswer((_) async => tWeatherModel);

        final result = await repository.getCurrentWeatherByCity(tCity);

        verify(mockLocalDataSource.getCachedCurrentWeather(tCity));
        verify(mockLocalDataSource.getLastSearchedCities());
        verify(mockLocalDataSource.getCachedCurrentWeather(fallbackCity));
        expect(result, equals(Right<Failure, CurrentWeather>(tWeatherModel)));
      },
    );
  });
}

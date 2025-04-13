import 'package:assessmentfounder/domain/entities/current_weather.dart';
import 'package:assessmentfounder/domain/repositories/weather_repository.dart';
import 'package:assessmentfounder/domain/usecases/get_current_weather.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_current_weather_test.mocks.dart';

@GenerateMocks([WeatherRepository])
void main() {
  late GetCurrentWeather usecase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    usecase = GetCurrentWeather(mockWeatherRepository);
  });

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

  test('should get current weather for the city from the repository', () async {
    when(
      mockWeatherRepository.getCurrentWeatherByCity(any),
    ).thenAnswer((_) async => Right(tCurrentWeather));

    final result = await usecase(Params.byCity(tCity));

    expect(result, Right(tCurrentWeather));
    verify(mockWeatherRepository.getCurrentWeatherByCity(tCity));
    verifyNoMoreInteractions(mockWeatherRepository);
  });

  test(
    'should get current weather by coordinates from the repository',
    () async {
      const tLatitude = 51.5074;
      const tLongitude = -0.1278;
      when(
        mockWeatherRepository.getCurrentWeatherByCoordinates(any, any),
      ).thenAnswer((_) async => Right(tCurrentWeather));

      final result = await usecase(Params.byCoordinates(tLatitude, tLongitude));

      expect(result, Right(tCurrentWeather));
      verify(
        mockWeatherRepository.getCurrentWeatherByCoordinates(
          tLatitude,
          tLongitude,
        ),
      );
      verifyNoMoreInteractions(mockWeatherRepository);
    },
  );
}

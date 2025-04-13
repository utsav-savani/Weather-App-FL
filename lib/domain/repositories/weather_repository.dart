import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/current_weather.dart';
import '../entities/forecast.dart';

abstract class WeatherRepository {
  /// Get current weather by city name
  Future<Either<Failure, CurrentWeather>> getCurrentWeatherByCity(String city);

  /// Get current weather by coordinates
  Future<Either<Failure, CurrentWeather>> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  );

  /// Get 5-day forecast by city name
  Future<Either<Failure, Forecast>> getForecastByCity(String city);

  /// Get 5-day forecast by coordinates
  Future<Either<Failure, Forecast>> getForecastByCoordinates(
    double latitude,
    double longitude,
  );

  /// Get last searched cities
  Future<List<String>> getLastSearchedCities();

  /// Save a city to the search history
  Future<void> saveToSearchHistory(String city);

  /// Clear search history
  Future<void> clearSearchHistory();
}

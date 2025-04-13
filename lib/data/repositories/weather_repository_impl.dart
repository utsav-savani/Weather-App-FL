import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/data/datasources/local/weather_local_data_source.dart';
import '/data/datasources/remote/weather_remote_data_source.dart';
import '/data/models/current_weather_model.dart';
import '/data/models/forecast_model.dart';
import '/domain/entities/current_weather.dart';
import '/domain/entities/forecast.dart';
import '/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;
  final Connectivity connectivity;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, CurrentWeather>> getCurrentWeatherByCity(
    String city,
  ) async {
    return _getCurrentWeather(
      () => remoteDataSource.getCurrentWeatherByCity(city),
      city,
    );
  }

  @override
  Future<Either<Failure, CurrentWeather>> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    return _getCurrentWeather(
      () =>
          remoteDataSource.getCurrentWeatherByCoordinates(latitude, longitude),
      '$latitude,$longitude',
    );
  }

  @override
  Future<Either<Failure, Forecast>> getForecastByCity(String city) async {
    return _getForecast(() => remoteDataSource.getForecastByCity(city), city);
  }

  @override
  Future<Either<Failure, Forecast>> getForecastByCoordinates(
    double latitude,
    double longitude,
  ) async {
    return _getForecast(
      () => remoteDataSource.getForecastByCoordinates(latitude, longitude),
      '$latitude,$longitude',
    );
  }

  @override
  Future<List<String>> getLastSearchedCities() async {
    try {
      return await localDataSource.getLastSearchedCities();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveToSearchHistory(String city) async {
    try {
      await localDataSource.addToSearchHistory(city);
    } catch (_) {}
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      await localDataSource.clearSearchHistory();
    } catch (_) {}
  }

  Future<Either<Failure, CurrentWeather>> _getCurrentWeather(
    Future<CurrentWeatherModel> Function() getRemote,
    String cacheKey,
  ) async {
    if (await _isConnected()) {
      try {
        final remoteWeather = await getRemote();

        try {
          await localDataSource.cacheCurrentWeather(cacheKey, remoteWeather);
        } catch (e) {
          print('Error caching current weather: $e');
        }

        await saveToSearchHistory(remoteWeather.cityName);
        return Right(remoteWeather);
      } on ServerException catch (e) {
        try {
          final localWeather = await localDataSource.getCachedCurrentWeather(
            cacheKey,
          );
          return Right(localWeather);
        } catch (_) {
          return Left(ServerFailure(message: e.message, code: e.code));
        }
      } on NetworkException catch (e) {
        try {
          final localWeather = await localDataSource.getCachedCurrentWeather(
            cacheKey,
          );
          return Right(localWeather);
        } catch (_) {
          return Left(NetworkFailure(message: e.message));
        }
      } catch (e) {
        try {
          final localWeather = await localDataSource.getCachedCurrentWeather(
            cacheKey,
          );
          return Right(localWeather);
        } catch (_) {
          return Left(UnexpectedFailure(message: e.toString()));
        }
      }
    } else {
      try {
        print('Offline mode - fetching current weather from cache: $cacheKey');
        final localWeather = await localDataSource.getCachedCurrentWeather(
          cacheKey,
        );
        return Right(localWeather);
      } on CacheException catch (e) {
        print('Cache exception when getting weather: ${e.message}');
        try {
          final searches = await getLastSearchedCities();
          for (final city in searches) {
            try {
              print('Trying fallback to recent search: $city');
              final localWeather = await localDataSource
                  .getCachedCurrentWeather(city);
              return Right(localWeather);
            } catch (_) {
              continue;
            }
          }
        } catch (_) {}

        return Left(CacheFailure(message: e.message));
      } catch (e) {
        print('Unexpected error when getting weather: $e');
        return Left(UnexpectedFailure(message: e.toString()));
      }
    }
  }

  Future<Either<Failure, Forecast>> _getForecast(
    Future<ForecastModel> Function() getRemote,
    String cacheKey,
  ) async {
    if (await _isConnected()) {
      try {
        final remoteForecast = await getRemote();

        try {
          await localDataSource.cacheForecast(cacheKey, remoteForecast);
        } catch (e) {
          print('Error caching forecast: $e');
        }

        await saveToSearchHistory(remoteForecast.cityName);
        return Right(remoteForecast);
      } on ServerException catch (e) {
        try {
          final localForecast = await localDataSource.getCachedForecast(
            cacheKey,
          );
          return Right(localForecast);
        } catch (_) {
          return Left(ServerFailure(message: e.message, code: e.code));
        }
      } on NetworkException catch (e) {
        try {
          final localForecast = await localDataSource.getCachedForecast(
            cacheKey,
          );
          return Right(localForecast);
        } catch (_) {
          return Left(NetworkFailure(message: e.message));
        }
      } catch (e) {
        try {
          final localForecast = await localDataSource.getCachedForecast(
            cacheKey,
          );
          return Right(localForecast);
        } catch (_) {
          return Left(UnexpectedFailure(message: e.toString()));
        }
      }
    } else {
      try {
        print('Offline mode - fetching forecast from cache: $cacheKey');
        final localForecast = await localDataSource.getCachedForecast(cacheKey);
        return Right(localForecast);
      } on CacheException catch (e) {
        print('Cache exception when getting forecast: ${e.message}');
        try {
          final searches = await getLastSearchedCities();
          for (final city in searches) {
            try {
              print('Trying fallback to recent search: $city');
              final localForecast = await localDataSource.getCachedForecast(
                city,
              );
              return Right(localForecast);
            } catch (_) {
              continue;
            }
          }
        } catch (_) {}

        return Left(CacheFailure(message: e.message));
      } catch (e) {
        print('Unexpected error when getting forecast: $e');
        return Left(UnexpectedFailure(message: e.toString()));
      }
    }
  }

  Future<bool> _isConnected() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

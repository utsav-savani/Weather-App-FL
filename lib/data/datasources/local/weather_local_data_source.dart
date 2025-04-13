import '/core/errors/exceptions.dart';
import '/core/storage/hive_storage.dart';
import '/core/utils/constants.dart';
import '/data/models/current_weather_model.dart';
import '/data/models/forecast_model.dart';

abstract class WeatherLocalDataSource {
  Future<CurrentWeatherModel> getCachedCurrentWeather(String city);
  Future<ForecastModel> getCachedForecast(String city);
  Future<void> cacheCurrentWeather(String city, CurrentWeatherModel weather);
  Future<void> cacheForecast(String city, ForecastModel forecast);
  Future<List<String>> getLastSearchedCities();
  Future<void> addToSearchHistory(String city);
  Future<void> clearSearchHistory();
  Future<bool> isCacheValid(String key);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final HiveStorage storage;

  WeatherLocalDataSourceImpl({required this.storage});

  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.fromEntries(
        data.entries.map(
          (entry) => MapEntry(entry.key.toString(), _sanitizeData(entry.value)),
        ),
      );
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }
    return data;
  }

  @override
  Future<CurrentWeatherModel> getCachedCurrentWeather(String city) async {
    try {
      final key = '${ApiConstants.currentWeatherKey}_$city';
      print('Getting cached weather for: $city');

      bool shouldCheckValidity = true;
      try {
        shouldCheckValidity = false;
      } catch (_) {
        shouldCheckValidity = false;
      }

      if (shouldCheckValidity && !await isCacheValid(key)) {
        print('Cache invalid for key: $key');
        throw CacheException(message: 'Cache expired or not found');
      }

      final data = await storage.get(key);

      if (data == null) {
        print('No data found for key: $key');
        throw CacheException(message: 'No cached data found');
      }

      print('Raw data type: ${data.runtimeType}');

      final sanitizedData = _sanitizeData(data);

      if (sanitizedData is! Map<String, dynamic>) {
        print('Data is not a Map: ${sanitizedData.runtimeType}');
        throw CacheException(message: 'Invalid data format');
      }

      print('Sanitized data keys: ${sanitizedData.keys.join(', ')}');

      try {
        final weather = CurrentWeatherModel.fromJson(sanitizedData);
        print('Successfully parsed CurrentWeatherModel');
        return weather;
      } catch (e, stack) {
        print('Error parsing model: $e');
        print('Stack trace: $stack');
        // Rethrow with more details
        throw CacheException(message: 'Failed to parse weather data: $e');
      }
    } catch (e) {
      print('getCachedCurrentWeather error: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<ForecastModel> getCachedForecast(String city) async {
    try {
      final key = '${ApiConstants.forecastKey}_$city';
      print('Getting cached forecast for: $city');

      bool shouldCheckValidity = true;
      try {
        shouldCheckValidity = false;
      } catch (_) {
        shouldCheckValidity = false;
      }

      if (shouldCheckValidity && !await isCacheValid(key)) {
        print('Cache invalid for key: $key');
        throw CacheException(message: 'Cache expired or not found');
      }

      final data = await storage.get(key);

      if (data == null) {
        print('No data found for key: $key');
        throw CacheException(message: 'No cached data found');
      }

      print('Raw data type: ${data.runtimeType}');

      final sanitizedData = _sanitizeData(data);

      if (sanitizedData is! Map<String, dynamic>) {
        print('Data is not a Map: ${sanitizedData.runtimeType}');
        throw CacheException(message: 'Invalid data format');
      }

      print('Sanitized data keys: ${sanitizedData.keys.join(', ')}');

      try {
        final forecast = ForecastModel.fromJson(sanitizedData);
        print('Successfully parsed ForecastModel');
        return forecast;
      } catch (e, stack) {
        print('Error parsing model: $e');
        print('Stack trace: $stack');
        throw CacheException(message: 'Failed to parse forecast data: $e');
      }
    } catch (e) {
      print('getCachedForecast error: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheCurrentWeather(
    String city,
    CurrentWeatherModel weather,
  ) async {
    try {
      final key = '${ApiConstants.currentWeatherKey}_$city';
      print('Caching weather for city: $city');

      final json = weather.toJson();
      await storage.put(key, json);
      await updateCacheTimestamp(key);

      print('Weather cached successfully for: $city');
    } catch (e) {
      print('Error caching weather: $e');
    }
  }

  @override
  Future<void> cacheForecast(String city, ForecastModel forecast) async {
    try {
      final key = '${ApiConstants.forecastKey}_$city';
      print('Caching forecast for city: $city');

      final json = forecast.toJson();
      await storage.put(key, json);
      await updateCacheTimestamp(key);

      print('Forecast cached successfully for: $city');
    } catch (e) {
      print('Error caching forecast: $e');
    }
  }

  @override
  Future<List<String>> getLastSearchedCities() async {
    try {
      final data = await storage.get(ApiConstants.lastSearchedCitiesKey);
      if (data == null) return [];

      if (data is List) {
        return data.map((item) => item.toString()).toList();
      }

      return [];
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  @override
  Future<void> addToSearchHistory(String city) async {
    try {
      final cities = await getLastSearchedCities();

      cities.removeWhere((e) => e.toLowerCase() == city.toLowerCase());

      cities.insert(0, city);

      if (cities.length > AppConstants.maxRecentSearches) {
        cities.removeLast();
      }

      await storage.put(ApiConstants.lastSearchedCitiesKey, cities);
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      await storage.put(ApiConstants.lastSearchedCitiesKey, []);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  @override
  Future<List<String>> getFavoriteLocations() async {
    try {
      final data = await storage.get(ApiConstants.favoriteLocationsKey);
      if (data == null) return [];

      if (data is List) {
        return data.map((item) => item.toString()).toList();
      }

      return [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  @override
  Future<bool> isCacheValid(String key) async {
    try {
      final timestampKey = '${key}_timestamp';
      final timestamp = await storage.get(timestampKey);

      if (timestamp == null) return false;

      int timestampValue;
      if (timestamp is int) {
        timestampValue = timestamp;
      } else {
        timestampValue = int.tryParse(timestamp.toString()) ?? 0;
      }

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestampValue);
      final now = DateTime.now();
      final diff = now.difference(cachedTime).inMinutes;

      return diff < AppConstants.cacheValidityDuration;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }

  Future<void> updateCacheTimestamp(String key) async {
    try {
      final timestampKey = '${key}_timestamp';
      final now = DateTime.now().millisecondsSinceEpoch;
      await storage.put(timestampKey, now);
    } catch (e) {
      print('Error updating cache timestamp: $e');
    }
  }
}

class ApiConstants {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String currentWeatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn';

  // Storage keys
  static const String currentWeatherKey = 'current_weather';
  static const String forecastKey = 'forecast';
  static const String lastFetchTimeKey = 'last_fetch_time';
  static const String lastSearchedCitiesKey = 'last_searched_cities';
  static const String favoriteLocationsKey = 'favorite_locations';
  static const String selectedThemeKey = 'selected_theme';
  static const String temperatureUnitKey = 'temperature_unit';
}

class AppConstants {
  static const int cacheValidityDuration = 30; // minutes
  static const int maxRecentSearches = 5;
  static const int maxFavoriteLocations = 5;
  static const double defaultLatitude = 51.5074;
  static const double defaultLongitude = -0.1278;
  static const String defaultCity = 'London';
}

enum TemperatureUnit { celsius, fahrenheit }

enum AppThemeMode { light, dark, system }

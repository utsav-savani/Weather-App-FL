import '/core/api/api_client.dart';
import '/data/models/current_weather_model.dart';
import '/data/models/forecast_model.dart';

abstract class WeatherRemoteDataSource {
  /// Gets the current weather information for a specific city.
  Future<CurrentWeatherModel> getCurrentWeatherByCity(String city);

  /// Gets the current weather information for specific coordinates.
  Future<CurrentWeatherModel> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  );

  /// Gets the 5-day forecast for a specific city.
  Future<ForecastModel> getForecastByCity(String city);

  /// Gets the 5-day forecast for specific coordinates.
  Future<ForecastModel> getForecastByCoordinates(
    double latitude,
    double longitude,
  );
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient apiClient;

  WeatherRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CurrentWeatherModel> getCurrentWeatherByCity(String city) async {
    final response = await apiClient.get(
      '/weather',
      queryParameters: {'q': city},
    );
    return CurrentWeatherModel.fromJson(response);
  }

  @override
  Future<CurrentWeatherModel> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final response = await apiClient.get(
      '/weather',
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    );
    return CurrentWeatherModel.fromJson(response);
  }

  @override
  Future<ForecastModel> getForecastByCity(String city) async {
    final response = await apiClient.get(
      '/forecast',
      queryParameters: {'q': city},
    );
    return ForecastModel.fromJson(response);
  }

  @override
  Future<ForecastModel> getForecastByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final response = await apiClient.get(
      '/forecast',
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    );
    return ForecastModel.fromJson(response);
  }
}

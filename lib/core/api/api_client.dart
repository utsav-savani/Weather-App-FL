import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '/core/config/app_config.dart';
import '/core/errors/exceptions.dart';

class ApiClient {
  final Dio _dio;
  final AppConfig _appConfig;

  ApiClient({required Dio dio, required AppConfig appConfig})
    : _dio = dio,
      _appConfig = appConfig {
    _init();
  }

  void _init() {
    _dio.options = BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      queryParameters: {'appid': _appConfig.apiKey, 'units': 'metric'},
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException();
      } else if (e.response != null) {
        throw ServerException(
          code: e.response?.statusCode ?? 500,
          message: e.response?.statusMessage ?? 'Server error',
        );
      } else {
        throw NetworkException(message: e.message ?? 'Network error');
      }
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}

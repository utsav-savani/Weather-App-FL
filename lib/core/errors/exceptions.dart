class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  final int code;

  ServerException({required this.code, required super.message});
}

class NetworkException extends AppException {
  NetworkException({required super.message});
}

class CacheException extends AppException {
  CacheException({required super.message});
}

class TimeoutException extends AppException {
  TimeoutException() : super(message: 'Connection timeout');
}

class UnexpectedException extends AppException {
  UnexpectedException({required super.message});
}

class LocationException extends AppException {
  LocationException({required super.message});
}

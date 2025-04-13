import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? code;

  const ServerFailure({required super.message, this.code});

  @override
  List<Object> get props => [message, code ?? 0];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

import 'package:equatable/equatable.dart';

import '/domain/entities/forecast.dart';

enum ForecastStatus { initial, loading, success, failure }

class ForecastState extends Equatable {
  final ForecastStatus status;
  final Forecast? forecast;
  final String? errorMessage;
  final String? cityName;
  final bool isRefreshing;

  const ForecastState({
    this.status = ForecastStatus.initial,
    this.forecast,
    this.errorMessage,
    this.cityName,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    status,
    forecast,
    errorMessage,
    cityName,
    isRefreshing,
  ];

  ForecastState copyWith({
    ForecastStatus? status,
    Forecast? forecast,
    String? errorMessage,
    String? cityName,
    bool? isRefreshing,
  }) {
    return ForecastState(
      status: status ?? this.status,
      forecast: forecast ?? this.forecast,
      errorMessage: errorMessage,
      cityName: cityName ?? this.cityName,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  bool get isInitial => status == ForecastStatus.initial;
  bool get isLoading => status == ForecastStatus.loading;
  bool get isSuccess => status == ForecastStatus.success;
  bool get isFailure => status == ForecastStatus.failure;
}

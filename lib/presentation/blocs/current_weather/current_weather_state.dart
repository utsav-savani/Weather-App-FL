import 'package:equatable/equatable.dart';

import '/domain/entities/current_weather.dart';

enum CurrentWeatherStatus { initial, loading, success, failure }

class CurrentWeatherState extends Equatable {
  final CurrentWeatherStatus status;
  final CurrentWeather? weather;
  final String? errorMessage;
  final String? cityName;
  final bool isRefreshing;

  const CurrentWeatherState({
    this.status = CurrentWeatherStatus.initial,
    this.weather,
    this.errorMessage,
    this.cityName,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    status,
    weather,
    errorMessage,
    cityName,
    isRefreshing,
  ];

  CurrentWeatherState copyWith({
    CurrentWeatherStatus? status,
    CurrentWeather? weather,
    String? errorMessage,
    String? cityName,
    bool? isRefreshing,
  }) {
    return CurrentWeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      errorMessage: errorMessage,
      cityName: cityName ?? this.cityName,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  bool get isInitial => status == CurrentWeatherStatus.initial;
  bool get isLoading => status == CurrentWeatherStatus.loading;
  bool get isSuccess => status == CurrentWeatherStatus.success;
  bool get isFailure => status == CurrentWeatherStatus.failure;
}

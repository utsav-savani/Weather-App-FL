import 'package:equatable/equatable.dart';

class CurrentWeather extends Equatable {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDeg;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final DateTime timestamp;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;

  const CurrentWeather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.timestamp,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
  });

  bool get isDay {
    final now = timestamp;
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  @override
  List<Object?> get props => [
    cityName,
    country,
    temperature,
    feelsLike,
    tempMin,
    tempMax,
    humidity,
    pressure,
    windSpeed,
    windDeg,
    weatherMain,
    weatherDescription,
    weatherIcon,
    timestamp,
    visibility,
    sunrise,
    sunset,
  ];
}

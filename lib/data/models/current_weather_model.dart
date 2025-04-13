import 'package:json_annotation/json_annotation.dart';

import '/domain/entities/current_weather.dart';

part 'current_weather_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CurrentWeatherModel extends CurrentWeather {
  const CurrentWeatherModel({
    required super.cityName,
    required super.country,
    required super.temperature,
    required super.feelsLike,
    required super.tempMin,
    required super.tempMax,
    required super.humidity,
    required super.pressure,
    required super.windSpeed,
    required super.windDeg,
    required super.weatherMain,
    required super.weatherDescription,
    required super.weatherIcon,
    required super.timestamp,
    required super.visibility,
    required super.sunrise,
    required super.sunset,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];
    final sys = json['sys'];

    return CurrentWeatherModel(
      cityName: json['name'],
      country: sys['country'],
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'],
      pressure: main['pressure'],
      windSpeed: (wind['speed'] as num).toDouble(),
      windDeg: wind['deg'],
      weatherMain: weather['main'],
      weatherDescription: weather['description'],
      weatherIcon: weather['icon'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      visibility: json['visibility'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000),
    );
  }

  Map<String, dynamic> toJson() => _$CurrentWeatherModelToJson(this);

  factory CurrentWeatherModel.fromEntity(CurrentWeather entity) {
    return CurrentWeatherModel(
      cityName: entity.cityName,
      country: entity.country,
      temperature: entity.temperature,
      feelsLike: entity.feelsLike,
      tempMin: entity.tempMin,
      tempMax: entity.tempMax,
      humidity: entity.humidity,
      pressure: entity.pressure,
      windSpeed: entity.windSpeed,
      windDeg: entity.windDeg,
      weatherMain: entity.weatherMain,
      weatherDescription: entity.weatherDescription,
      weatherIcon: entity.weatherIcon,
      timestamp: entity.timestamp,
      visibility: entity.visibility,
      sunrise: entity.sunrise,
      sunset: entity.sunset,
    );
  }
}

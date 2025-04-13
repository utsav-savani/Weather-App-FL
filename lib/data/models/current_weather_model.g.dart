// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentWeatherModel _$CurrentWeatherModelFromJson(Map<String, dynamic> json) =>
    CurrentWeatherModel(
      cityName: json['cityName'] as String,
      country: json['country'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      pressure: (json['pressure'] as num).toInt(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDeg: (json['windDeg'] as num).toInt(),
      weatherMain: json['weatherMain'] as String,
      weatherDescription: json['weatherDescription'] as String,
      weatherIcon: json['weatherIcon'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      visibility: (json['visibility'] as num).toInt(),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
    );

Map<String, dynamic> _$CurrentWeatherModelToJson(
        CurrentWeatherModel instance) =>
    <String, dynamic>{
      'cityName': instance.cityName,
      'country': instance.country,
      'temperature': instance.temperature,
      'feelsLike': instance.feelsLike,
      'tempMin': instance.tempMin,
      'tempMax': instance.tempMax,
      'humidity': instance.humidity,
      'pressure': instance.pressure,
      'windSpeed': instance.windSpeed,
      'windDeg': instance.windDeg,
      'weatherMain': instance.weatherMain,
      'weatherDescription': instance.weatherDescription,
      'weatherIcon': instance.weatherIcon,
      'timestamp': instance.timestamp.toIso8601String(),
      'visibility': instance.visibility,
      'sunrise': instance.sunrise.toIso8601String(),
      'sunset': instance.sunset.toIso8601String(),
    };

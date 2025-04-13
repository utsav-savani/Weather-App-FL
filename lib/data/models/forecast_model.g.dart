// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastModel _$ForecastModelFromJson(Map<String, dynamic> json) =>
    ForecastModel(
      cityName: json['cityName'] as String,
      country: json['country'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ForecastItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ForecastModelToJson(ForecastModel instance) =>
    <String, dynamic>{
      'cityName': instance.cityName,
      'country': instance.country,
      'items': instance.items,
    };

ForecastItemModel _$ForecastItemModelFromJson(Map<String, dynamic> json) =>
    ForecastItemModel(
      dateTime: DateTime.parse(json['dateTime'] as String),
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
      visibility: (json['visibility'] as num).toInt(),
      rainVolume: (json['rainVolume'] as num?)?.toDouble(),
      snowVolume: (json['snowVolume'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ForecastItemModelToJson(ForecastItemModel instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime.toIso8601String(),
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
      'visibility': instance.visibility,
      'rainVolume': instance.rainVolume,
      'snowVolume': instance.snowVolume,
    };

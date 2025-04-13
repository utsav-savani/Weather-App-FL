import 'package:json_annotation/json_annotation.dart';

import '/domain/entities/forecast.dart';

part 'forecast_model.g.dart';

@JsonSerializable()
class ForecastModel extends Forecast {
  const ForecastModel({
    required super.cityName,
    required super.country,
    required List<ForecastItemModel> super.items,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final city = json['city'];
    final list = json['list'] as List;

    return ForecastModel(
      cityName: city['name'],
      country: city['country'],
      items: list.map((item) => ForecastItemModel.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final itemsList =
        items.map((item) {
          return (item).toJson();
                  throw UnsupportedError(
            'Cannot convert a non-ForecastItemModel to JSON: $item',
          );
        }).toList();

    return {
      'city': {'name': cityName, 'country': country},
      'list': itemsList,
    };
  }

  @override
  List<ForecastItemModel> get items =>
      super.items.map((e) => e as ForecastItemModel).toList();
}

@JsonSerializable()
class ForecastItemModel extends ForecastItem {
  const ForecastItemModel({
    required super.dateTime,
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
    required super.visibility,
    super.rainVolume,
    super.snowVolume,
  });

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];

    return ForecastItemModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
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
      visibility: json['visibility'],
      rainVolume:
          json['rain'] != null
              ? (json['rain']['3h'] as num?)?.toDouble()
              : null,
      snowVolume:
          json['snow'] != null
              ? (json['snow']['3h'] as num?)?.toDouble()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
        'pressure': pressure,
      },
      'weather': [
        {
          'main': weatherMain,
          'description': weatherDescription,
          'icon': weatherIcon,
        },
      ],
      'wind': {'speed': windSpeed, 'deg': windDeg},
      'visibility': visibility,
      if (rainVolume != null) 'rain': {'3h': rainVolume},
      if (snowVolume != null) 'snow': {'3h': snowVolume},
    };
  }
}

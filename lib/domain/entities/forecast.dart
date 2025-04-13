import 'package:equatable/equatable.dart';

class Forecast extends Equatable {
  final String cityName;
  final String country;
  final List<ForecastItem> items;

  const Forecast({
    required this.cityName,
    required this.country,
    required this.items,
  });

  @override
  List<Object?> get props => [cityName, country, items];

  Map<DateTime, List<ForecastItem>> get dailyForecasts {
    final Map<DateTime, List<ForecastItem>> result = {};

    for (var item in items) {
      final date = DateTime(
        item.dateTime.year,
        item.dateTime.month,
        item.dateTime.day,
      );

      if (!result.containsKey(date)) {
        result[date] = [];
      }

      result[date]!.add(item);
    }

    return result;
  }

  List<DailyForecast> get dailyForecastData {
    final Map<DateTime, List<ForecastItem>> daily = dailyForecasts;
    final List<DailyForecast> result = [];

    daily.forEach((date, items) {
      double minTemp = double.infinity;
      double maxTemp = double.negativeInfinity;
      String mainCondition = '';
      String icon = '';

      final Map<String, int> conditionCounts = {};

      for (var item in items) {
        if (item.temperature < minTemp) {
          minTemp = item.temperature;
        }
        if (item.temperature > maxTemp) {
          maxTemp = item.temperature;
        }

        final condition = item.weatherMain;
        conditionCounts[condition] = (conditionCounts[condition] ?? 0) + 1;
      }

      int maxCount = 0;
      conditionCounts.forEach((condition, count) {
        if (count > maxCount) {
          maxCount = count;
          mainCondition = condition;
        }
      });

      for (var item in items) {
        if (item.weatherMain == mainCondition) {
          icon = item.weatherIcon;
          break;
        }
      }

      result.add(
        DailyForecast(
          date: date,
          minTemperature: minTemp,
          maxTemperature: maxTemp,
          weatherMain: mainCondition,
          weatherIcon: icon,
        ),
      );
    });

    result.sort((a, b) => a.date.compareTo(b.date));

    return result;
  }
}

class ForecastItem extends Equatable {
  final DateTime dateTime;
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
  final int visibility;
  final double? rainVolume;
  final double? snowVolume;

  const ForecastItem({
    required this.dateTime,
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
    required this.visibility,
    this.rainVolume,
    this.snowVolume,
  });

  @override
  List<Object?> get props => [
    dateTime,
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
    visibility,
    rainVolume,
    snowVolume,
  ];
}

class DailyForecast extends Equatable {
  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final String weatherMain;
  final String weatherIcon;

  const DailyForecast({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.weatherMain,
    required this.weatherIcon,
  });

  @override
  List<Object?> get props => [
    date,
    minTemperature,
    maxTemperature,
    weatherMain,
    weatherIcon,
  ];
}

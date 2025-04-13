import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/theme/app_colors.dart';
import '/core/utils/constants.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension DateTimeExtension on DateTime {
  String get formattedDate {
    return DateFormat('EEEE, MMMM d').format(this);
  }

  String get formattedDay {
    return DateFormat('EEE').format(this);
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(this);
  }

  String get formattedDateTime {
    return DateFormat('MMM d, yyyy - h:mm a').format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension DoubleExtension on double {
  String get asTemperature {
    return '${round()}°';
  }

  String temperatureWithUnit(TemperatureUnit unit) {
    return unit == TemperatureUnit.celsius
        ? '${round()}°C'
        : '${(this * 9 / 5 + 32).round()}°F';
  }

  double toFahrenheit() {
    return this * 9 / 5 + 32;
  }

  double toCelsius() {
    return (this - 32) * 5 / 9;
  }
}

extension IntExtension on int {
  String get asTemperature {
    return '$this°';
  }

  DateTime get toDateTime {
    return DateTime.fromMillisecondsSinceEpoch(this * 1000);
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isPhone => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  bool get isDesktop => screenWidth >= 900;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  double get topPadding => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;
}

extension WeatherCondition on String {
  List<Color> get conditionColors {
    switch (toLowerCase()) {
      case 'clear':
        return AppColors.sunnyGradient;
      case 'clouds':
        return AppColors.cloudyGradient;
      case 'rain':
      case 'drizzle':
        return AppColors.rainyGradient;
      case 'thunderstorm':
        return AppColors.thunderstormGradient;
      case 'snow':
        return AppColors.snowyGradient;
      default:
        return AppColors.primaryGradient;
    }
  }

  String get weatherIcon {
    switch (toLowerCase()) {
      case 'clear':
        return '01d';
      case 'few clouds':
        return '02d';
      case 'scattered clouds':
        return '03d';
      case 'broken clouds':
      case 'overcast clouds':
        return '04d';
      case 'shower rain':
        return '09d';
      case 'rain':
        return '10d';
      case 'thunderstorm':
        return '11d';
      case 'snow':
        return '13d';
      case 'mist':
      case 'fog':
      case 'haze':
        return '50d';
      default:
        return '01d';
    }
  }
}

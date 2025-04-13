import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/utils/extensions.dart';
import '/domain/entities/forecast.dart';
import '/presentation/widgets/weather_icon.dart';
import '../../core/utils/constants.dart';
import '../blocs/settings/settings_cubit.dart';
import '../blocs/settings/settings_state.dart';
import 'forecast_custom_painter.dart';

class ForecastCard extends StatefulWidget {
  final Forecast forecast;

  const ForecastCard({super.key, required this.forecast});

  @override
  State<ForecastCard> createState() => _ForecastCardState();
}

class _ForecastCardState extends State<ForecastCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _sharedController;

  @override
  void initState() {
    super.initState();
    _sharedController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sharedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyForecast = widget.forecast.dailyForecastData;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '5-Day Forecast',
              style: AppTextStyles.headlineMedium,
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),
            ...dailyForecast
                .map((day) => _buildDailyForecast(context, day))
                .toList()
                .animate(interval: 100.ms)
                .slideX(
                  begin: 0.2,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 500.ms,
      curve: Curves.elasticOut,
    );
  }

  Widget _buildDailyForecast(BuildContext context, DailyForecast day) {
    if (day.date.isSameDay(DateTime.now())) {
      return const SizedBox.shrink();
    }

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              borderRadius: BorderRadius.circular(8),
              color:
                  isHovered
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                      : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    day.date.formattedDay,
                    style: AppTextStyles.forecastDay.copyWith(
                      fontWeight: isHovered ? FontWeight.bold : null,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildWeatherAnimation(day.weatherIcon, day.weatherMain),
                    const SizedBox(width: 8),
                    Text(
                      day.weatherMain,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: isHovered ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, settingsState) {
                        final unit =
                            settingsState.temperatureUnit ==
                                    TemperatureUnit.celsius
                                ? '°C'
                                : '°F';
                        final maxTemp =
                            settingsState.temperatureUnit ==
                                    TemperatureUnit.celsius
                                ? day.maxTemperature
                                : day.maxTemperature.toFahrenheit();

                        return Text(
                          '${maxTemp.round()}$unit',
                          style: AppTextStyles.forecastTemperature.copyWith(
                            fontWeight: isHovered ? FontWeight.w400 : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, settingsState) {
                        final unit =
                            settingsState.temperatureUnit ==
                                    TemperatureUnit.celsius
                                ? '°C'
                                : '°F';
                        final minTemp =
                            settingsState.temperatureUnit ==
                                    TemperatureUnit.celsius
                                ? day.minTemperature
                                : day.minTemperature.toFahrenheit();

                        return Text(
                          '${minTemp.round()}$unit',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherAnimation(String iconCode, String weatherMain) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          WeatherIcon(iconCode: iconCode, size: 40),

          if (weatherMain.toLowerCase().contains('rain'))
            _buildRainAnimationOverlay(),
          if (weatherMain.toLowerCase().contains('snow'))
            _buildSnowAnimationOverlay(),
          if (weatherMain.toLowerCase().contains('cloud'))
            _buildCloudAnimationOverlay(),
          if (weatherMain.toLowerCase().contains('clear') ||
              weatherMain.toLowerCase().contains('sun'))
            _buildSunAnimationOverlay(),
        ],
      ),
    );
  }

  Widget _buildRainAnimationOverlay() {
    return AnimatedBuilder(
      animation: _sharedController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(40, 40),
          painter: RainPainter(animation: _sharedController),
        );
      },
    );
  }

  Widget _buildSnowAnimationOverlay() {
    return AnimatedBuilder(
      animation: _sharedController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(40, 40),
          painter: SnowPainter(animation: _sharedController),
        );
      },
    );
  }

  Widget _buildCloudAnimationOverlay() {
    return AnimatedBuilder(
      animation: _sharedController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(40, 40),
          painter: CloudPainter(animation: _sharedController),
        );
      },
    );
  }

  Widget _buildSunAnimationOverlay() {
    return AnimatedBuilder(
      animation: _sharedController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(40, 40),
          painter: SunPainter(animation: _sharedController),
        );
      },
    );
  }
}

class HourlyForecastCard extends StatefulWidget {
  final Forecast forecast;

  const HourlyForecastCard({super.key, required this.forecast});

  @override
  State<HourlyForecastCard> createState() => _HourlyForecastCardState();
}

class _HourlyForecastCardState extends State<HourlyForecastCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayAfterTomorrow = DateTime(now.year, now.month, now.day + 2);

    final hourlyItems =
        widget.forecast.items
            .where((item) {
              return item.dateTime.isAfter(now) &&
                  item.dateTime.isBefore(dayAfterTomorrow);
            })
            .take(8)
            .toList();

    return Card(
          elevation: 3,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hourly Forecast', style: AppTextStyles.headlineMedium)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hourlyItems.length,
                    itemBuilder: (context, index) {
                      final item = hourlyItems[index];
                      return _buildHourlyItem(context, item, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildHourlyItem(BuildContext context, ForecastItem item, int index) {
    final isDay = item.dateTime.hour > 6 && item.dateTime.hour < 18;

    final animationDelay = index * 0.2;
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        animationDelay.clamp(0.0, 0.8),
        (animationDelay + 0.2).clamp(0.0, 1.0),
        curve: Curves.easeInOut,
      ),
    );

    return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDay
                          ? [
                            item.weatherMain.conditionColors.first.withOpacity(
                              0.3 + animation.value * 0.1,
                            ),
                            item.weatherMain.conditionColors.first.withOpacity(
                              0.1 + animation.value * 0.05,
                            ),
                          ]
                          : [
                            AppColors.nightGradient.first.withOpacity(
                              0.3 + animation.value * 0.1,
                            ),
                            AppColors.nightGradient.first.withOpacity(
                              0.1 + animation.value * 0.05,
                            ),
                          ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.05 + animation.value * 0.05,
                    ),
                    blurRadius: 4 + animation.value * 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.dateTime.formattedTime,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  _buildAnimatedHourlyIcon(item),
                  const SizedBox(height: 8),
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settingsState) {
                      final unit =
                          settingsState.temperatureUnit ==
                                  TemperatureUnit.celsius
                              ? '°C'
                              : '°F';
                      final temp =
                          settingsState.temperatureUnit ==
                                  TemperatureUnit.celsius
                              ? item.temperature
                              : item.temperature.toFahrenheit();

                      return Text(
                        '${temp.round()}$unit',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  Text(
                    item.weatherMain,
                    style: AppTextStyles.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 500.ms)
        .moveY(begin: 20, end: 0, duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildAnimatedHourlyIcon(ForecastItem item) {
    return Stack(
      alignment: Alignment.center,
      children: [
        WeatherIcon(iconCode: item.weatherIcon, size: 40),

        if (item.weatherMain.toLowerCase().contains('rain'))
          _buildWeatherAnimation('rain'),
        if (item.weatherMain.toLowerCase().contains('snow'))
          _buildWeatherAnimation('snow'),
        if (item.weatherMain.toLowerCase().contains('thunder'))
          _buildWeatherAnimation('thunder'),
        if (item.weatherMain.toLowerCase().contains('cloud'))
          _buildWeatherAnimation('cloud'),
      ],
    );
  }

  Widget _buildWeatherAnimation(String type) {
    switch (type) {
      case 'rain':
        return SizedBox(
          width: 40,
          height: 40,
          child: CustomPaint(
            painter: RainPainter(animation: _animationController),
          ),
        );
      case 'snow':
        return SizedBox(
          width: 40,
          height: 40,
          child: CustomPaint(
            painter: SnowPainter(animation: _animationController),
          ),
        );
      case 'thunder':
        return Icon(
              Icons.flash_on,
              color: Colors.yellow.withOpacity(0.7),
              size: 20,
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .fadeIn(duration: 150.ms)
            .scaleXY(begin: 0.8, end: 1.2, duration: 250.ms)
            .fadeOut(delay: 300.ms);
      case 'cloud':
        return SizedBox(
          width: 40,
          height: 40,
          child: CustomPaint(
            painter: CloudPainter(animation: _animationController),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

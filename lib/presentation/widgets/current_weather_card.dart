import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/utils/extensions.dart';
import '/domain/entities/current_weather.dart';
import '/presentation/widgets/weather_icon.dart';
import '../../core/utils/constants.dart';
import '../blocs/settings/settings_cubit.dart';
import '../blocs/settings/settings_state.dart';
import 'forecast_custom_painter.dart';

class CurrentWeatherCard extends StatefulWidget {
  final CurrentWeather weather;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _temperatureAnimation;
  late Animation<double> _detailsAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _temperatureAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _detailsAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.weather.weatherMain.conditionColors;
    final isDay = widget.weather.isDay;

    return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDay ? gradientColors : AppColors.nightGradient,
              ),
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildMainInfo(context),
                    const SizedBox(height: 20),
                    Transform.scale(
                      scale: _detailsAnimation.value,
                      child: _buildDetails(context),
                    ),
                  ],
                );
              },
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutQuint,
        );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  widget.weather.cityName,
                  style: AppTextStyles.cityName.copyWith(
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .moveX(begin: -10, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 4),
            Text(
                  '${widget.weather.country} • ${DateTime.now().formattedDate}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .moveX(begin: -10, end: 0, curve: Curves.easeOutQuad),
          ],
        ),
        if (widget.onRefresh != null) _buildRefreshButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
          onPressed: widget.isLoading ? null : widget.onRefresh,
          icon:
              widget.isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(Icons.refresh_rounded, color: Colors.white),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms)
        .rotate(begin: -0.5, end: 0);
  }

  Widget _buildMainInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _temperatureAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _temperatureAnimation.value,
                  alignment: Alignment.centerLeft,
                  child: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settingsState) {
                      final unit =
                          settingsState.temperatureUnit ==
                                  TemperatureUnit.celsius
                              ? '°C'
                              : '°F';
                      final temp =
                          settingsState.temperatureUnit ==
                                  TemperatureUnit.celsius
                              ? widget.weather.temperature
                              : widget.weather.temperature.toFahrenheit();

                      return Text(
                        '${temp.round()}$unit',
                        style: AppTextStyles.temperature.copyWith(
                          color: Colors.white,
                          fontSize: 54.0,
                          shadows: [
                            const Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                    final unit =
                        settingsState.temperatureUnit == TemperatureUnit.celsius
                            ? '°C'
                            : '°F';
                    final feelsLike =
                        settingsState.temperatureUnit == TemperatureUnit.celsius
                            ? widget.weather.feelsLike
                            : widget.weather.feelsLike.toFahrenheit();

                    return Text(
                      'Feels like ${feelsLike.round()}$unit',
                      style: AppTextStyles.temperatureFeelsLike.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    );
                  },
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .moveY(begin: 10, end: 0, curve: Curves.easeOut),
          ],
        ),
        Column(
          children: [
            _buildWeatherAnimation(),
            Text(
                  widget.weather.weatherDescription.capitalizeWords,
                  style: AppTextStyles.weatherCondition.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms)
                .moveY(begin: 10, end: 0, curve: Curves.easeOut),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required int delayMs,
  }) {
    if (title == 'Min' || title == 'Max') {
      return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final unit =
              settingsState.temperatureUnit == TemperatureUnit.celsius
                  ? '°C'
                  : '°F';

          final numericValue =
              double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          final convertedValue =
              settingsState.temperatureUnit == TemperatureUnit.celsius
                  ? numericValue
                  : numericValue.toFahrenheit();

          return Column(
                children: [
                  Icon(icon, color: Colors.white70, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${convertedValue.round()}$unit',
                    style: AppTextStyles.weatherDetailValue.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delayMs))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeOut,
              );
        },
      );
    }

    return Column(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.weatherDetailValue.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delayMs))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOut,
        );
  }

  Widget _buildWeatherAnimation() {
    final weatherMain = widget.weather.weatherMain.toLowerCase();

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedWeatherIcon(iconCode: widget.weather.weatherIcon),

        if (weatherMain.contains('rain'))
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: RainPainter(animation: _animationController),
            ),
          ),
        if (weatherMain.contains('snow'))
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: SnowPainter(animation: _animationController),
            ),
          ),
        if (weatherMain.contains('cloud'))
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: CloudPainter(animation: _animationController),
            ),
          ),
        if (weatherMain.contains('clear') || weatherMain.contains('sun'))
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: SunPainter(animation: _animationController),
            ),
          ),
        if (weatherMain.contains('thunder')) _buildThunderEffect(),
      ],
    );
  }

  Widget _buildThunderEffect() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: Icon(
              Icons.flash_on,
              color: Colors.yellow.withOpacity(0.8),
              size: 40,
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .fadeIn(duration: 100.ms)
            .scaleXY(begin: 1.0, end: 1.5, duration: 200.ms)
            .fadeOut(delay: 300.ms, duration: 300.ms),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    icon: Icons.thermostat,
                    title: 'Min',
                    value: widget.weather.tempMin.asTemperature,
                    delayMs: 0,
                  ),
                  _buildDetailItem(
                    icon: Icons.thermostat,
                    title: 'Max',
                    value: widget.weather.tempMax.asTemperature,
                    delayMs: 100,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    icon: Icons.water_drop,
                    title: 'Humidity',
                    value: '${widget.weather.humidity}%',
                    delayMs: 200,
                  ),
                  _buildDetailItem(
                    icon: Icons.air,
                    title: 'Wind',
                    value: '${widget.weather.windSpeed} m/s',
                    delayMs: 300,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    icon: Icons.visibility,
                    title: 'Visibility',
                    value:
                        '${(widget.weather.visibility / 1000).toStringAsFixed(1)} km',
                    delayMs: 400,
                  ),
                  _buildDetailItem(
                    icon: Icons.compress,
                    title: 'Pressure',
                    value: '${widget.weather.pressure} hPa',
                    delayMs: 500,
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms, delay: 500.ms)
        .moveY(begin: 20, end: 0, curve: Curves.easeOutQuad);
  }
}

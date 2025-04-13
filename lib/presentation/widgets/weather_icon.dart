import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '/core/theme/app_colors.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 50});

  @override
  Widget build(BuildContext context) {
    final url = 'https://openweathermap.org/img/wn/$iconCode@2x.png';

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: size * 0.8,
          ),
    );
  }
}

class AnimatedWeatherIcon extends StatefulWidget {
  final String iconCode;
  final double size;

  const AnimatedWeatherIcon({super.key, required this.iconCode, this.size = 100});

  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRain =
        widget.iconCode.contains('09') || widget.iconCode.contains('10');
    final isSnow = widget.iconCode.contains('13');
    final isThunder = widget.iconCode.contains('11');
    final isClear = widget.iconCode.contains('01');
    final isCloudy =
        widget.iconCode.contains('02') ||
        widget.iconCode.contains('03') ||
        widget.iconCode.contains('04');

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isRain) _buildRainEffect(),
        if (isSnow) _buildSnowEffect(),
        if (isThunder) _buildThunderEffect(),
        if (isClear) _buildSunEffect(),
        if (isCloudy) _buildCloudEffect(),

        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: child,
              ),
            );
          },
          child: WeatherIcon(iconCode: widget.iconCode, size: widget.size),
        ),
      ],
    );
  }

  Widget _buildRainEffect() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: List.generate(8, (index) {
          final random = math.Random(index);
          final xPos = random.nextDouble() * widget.size;
          final delay = random.nextInt(1000);

          return Positioned(
            left: xPos,
            top: -10,
            child: Container(
                  width: 2,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 200.ms)
                .moveY(
                  begin: 0,
                  end: widget.size,
                  duration: 1500.ms,
                  delay: Duration(milliseconds: delay),
                  curve: Curves.easeIn,
                )
                .fadeOut(delay: 1200.ms, duration: 300.ms),
          );
        }),
      ),
    );
  }

  Widget _buildSnowEffect() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: List.generate(6, (index) {
          final random = math.Random(index);
          final xPos = random.nextDouble() * widget.size;
          final size = 2.0 + random.nextDouble() * 2;
          final delay = random.nextInt(1000);

          return Positioned(
            left: xPos,
            top: -size,
            child: Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .moveY(
                  begin: 0,
                  end: widget.size,
                  duration: 2.seconds,
                  delay: Duration(milliseconds: delay),
                  curve: Curves.linear,
                )
                .moveX(
                  begin: 0,
                  end: random.nextBool() ? 10 : -10,
                  duration: 2.seconds,
                  delay: Duration(milliseconds: delay),
                  curve: Curves.easeInOut,
                ),
          );
        }),
      ),
    );
  }

  Widget _buildThunderEffect() {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      child: Icon(
            Icons.bolt,
            color: Colors.yellow.withOpacity(0.7),
            size: widget.size * 0.4,
          )
          .animate(onPlay: (controller) => controller.repeat())
          .custom(
            duration: 1.seconds,
            builder:
                (context, value, child) => Opacity(
                  opacity: math.sin(value * math.pi * 2) * 0.5 + 0.5,
                  child: child,
                ),
          ),
    );
  }

  Widget _buildSunEffect() {
    return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.yellow.withOpacity(0.4),
                Colors.orange.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 2.seconds,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildCloudEffect() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: widget.size * 0.2,
            top: widget.size * 0.3,
            child: Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(widget.size * 0.15),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveX(
                  begin: -5,
                  end: 5,
                  duration: 3.seconds,
                  curve: Curves.easeInOut,
                ),
          ),
          Positioned(
            right: widget.size * 0.2,
            bottom: widget.size * 0.3,
            child: Container(
                  width: widget.size * 0.25,
                  height: widget.size * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(widget.size * 0.125),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveX(
                  begin: 5,
                  end: -5,
                  duration: 4.seconds,
                  curve: Curves.easeInOut,
                ),
          ),
        ],
      ),
    );
  }
}

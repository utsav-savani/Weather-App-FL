import 'dart:math' as math;

import 'package:flutter/material.dart';

class RainPainter extends CustomPainter {
  final Animation<double> animation;

  RainPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint =
        Paint()
          ..color = Colors.blue.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 10; i++) {
      final x = random.nextDouble() * size.width;
      final length = 4 + random.nextDouble() * 6;
      final offset = random.nextDouble() * size.height;

      final time = DateTime.now().millisecondsSinceEpoch / 1000;
      final cycle = (time * 0.5) % 1.0;

      final startY = (offset + cycle * size.height) % size.height;
      final endY = startY + length;

      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}

class SnowPainter extends CustomPainter {
  final Animation<double> animation;

  SnowPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    final time = DateTime.now().millisecondsSinceEpoch / 1000;

    for (int i = 0; i < 8; i++) {
      final xBase = random.nextDouble() * size.width;

      final sway = math.sin((time + i) * 2) * 3;
      final x = xBase + sway;

      final cycle = (time * 0.3) % 1.0;

      final offset = random.nextDouble() * size.height;
      final y = (offset + cycle * size.height) % size.height;

      final radius = 1.0 + random.nextDouble() * 1.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) => true;
}

class CloudPainter extends CustomPainter {
  final Animation<double> animation;

  CloudPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final baseCloudPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    final shadowPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final cloudOffset = math.sin(animation.value * math.pi * 2) * 5;

    _drawCloud(
      canvas,
      size,
      Offset(size.width * 0.5 + cloudOffset + 2, size.height * 0.5 + 2),
      size.width * 0.3,
      shadowPaint,
    );

    _drawCloud(
      canvas,
      size,
      Offset(size.width * 0.5 + cloudOffset, size.height * 0.5),
      size.width * 0.3,
      baseCloudPaint,
    );
  }

  void _drawCloud(
    Canvas canvas,
    Size size,
    Offset center,
    double cloudWidth,
    Paint paint,
  ) {
    final cloudPath = Path();

    cloudPath.addOval(
      Rect.fromCenter(
        center: center,
        width: cloudWidth,
        height: cloudWidth * 0.6,
      ),
    );

    cloudPath.addOval(
      Rect.fromCenter(
        center: Offset(
          center.dx - cloudWidth * 0.25,
          center.dy - cloudWidth * 0.15,
        ),
        width: cloudWidth * 0.5,
        height: cloudWidth * 0.45,
      ),
    );

    cloudPath.addOval(
      Rect.fromCenter(
        center: Offset(
          center.dx + cloudWidth * 0.2,
          center.dy - cloudWidth * 0.1,
        ),
        width: cloudWidth * 0.4,
        height: cloudWidth * 0.4,
      ),
    );

    canvas.drawPath(cloudPath, paint);
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) => true;
}

class SunPainter extends CustomPainter {
  final Animation<double> animation;

  SunPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    final pulseScale = 0.9 + math.sin(animation.value * math.pi * 2) * 0.1;

    final sunPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.yellow,
              Colors.yellow.withOpacity(0.7),
              Colors.yellow.withOpacity(0.0),
            ],
            stops: const [0.4, 0.7, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));

    canvas.drawCircle(center, radius * pulseScale, sunPaint);

    final rayPaint =
        Paint()
          ..color = Colors.yellow.withOpacity(0.7)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final rotatedAngle = angle + animation.value * math.pi / 4;

      final innerRadius =
          radius * (1.1 + math.sin(animation.value * math.pi * 2 + i) * 0.05);
      final outerRadius =
          radius * (1.4 + math.sin(animation.value * math.pi * 2 + i) * 0.1);

      final inner = Offset(
        center.dx + innerRadius * math.cos(rotatedAngle),
        center.dy + innerRadius * math.sin(rotatedAngle),
      );

      final outer = Offset(
        center.dx + outerRadius * math.cos(rotatedAngle),
        center.dy + outerRadius * math.sin(rotatedAngle),
      );

      canvas.drawLine(inner, outer, rayPaint);
    }
  }

  @override
  bool shouldRepaint(SunPainter oldDelegate) => true;
}

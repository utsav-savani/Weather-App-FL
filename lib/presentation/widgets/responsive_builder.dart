import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, _getDeviceType(constraints));
      },
    );
  }

  DeviceType _getDeviceType(BoxConstraints constraints) {
    if (constraints.maxWidth < 600) {
      return DeviceType.mobile;
    } else if (constraints.maxWidth < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.mobile:
            return mobile;
        }
      },
    );
  }
}

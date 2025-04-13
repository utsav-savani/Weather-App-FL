import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionHelper {
  // Check if location services are enabled and request permission if needed
  static Future<bool> checkAndRequestLocationPermission(
    BuildContext context,
  ) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDisabledDialog(context);
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog(context);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentlyDeniedDialog(context);
      return false;
    }

    return true;
  }

  // Dialog to show when location services are disabled
  static void _showLocationDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Please enable location services in your device settings to access weather information for your current location.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to show when permissions are denied
  static void _showPermissionDeniedDialog(BuildContext context) {
    String platformSpecificMessage =
        'This app needs location permission to show weather information for your current location.';

    if (Platform.isMacOS) {
      platformSpecificMessage =
          'This app needs location permission to show weather information for your current location. Please check your macOS privacy settings.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: Text(platformSpecificMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to show when permissions are permanently denied
  static void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    String platformSpecificMessage =
        'Location permission is permanently denied. Please enable it in app settings.';
    String buttonText = 'Open Settings';

    if (Platform.isMacOS) {
      platformSpecificMessage =
          'Location permission is denied. Please enable it in macOS System Preferences > Security & Privacy > Privacy > Location Services.';
      buttonText = 'Open System Preferences';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content: Text(platformSpecificMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}

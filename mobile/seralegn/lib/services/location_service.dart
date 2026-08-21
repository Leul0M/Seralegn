import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  /// Request native location permission and fetch current device position
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled on your device. Please enable GPS.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions were denied.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied. Please enable them in App Settings.',
            ),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return position;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
      return null;
    }
  }

  /// Open native Android maps app / location sharing intent using geo: URI scheme or web Google Maps fallback
  static Future<void> shareNativeLocation({
    required double latitude,
    required double longitude,
    String label = 'Job Location',
    required BuildContext context,
  }) async {
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(label)})');
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch maps application.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share location: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}

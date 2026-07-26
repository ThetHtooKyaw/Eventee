import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _keyHasPermission = 'has_location_permission';
  static const String skipToken = 'skipped_location_permission';

  Future<Object> requestLocationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasPermissionBefore = prefs.getBool(_keyHasPermission) ?? false;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Failure(
          response: 'Location services are disabled on this device.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (hasPermissionBefore &&
          (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse)) {
        return Success(response: skipToken);
      }

      await prefs.setBool(_keyHasPermission, true);

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Failure(
            response: 'Location permission was denied by the user.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Failure(
          response:
              'Location permissions are permanently denied. Please enable them in your device settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return Failure(
          response: 'No address data found for these coordinates.',
        );
      }

      final placemark = placemarks.first;
      final address = '${placemark.locality}, ${placemark.country}';

      return Success(response: address);
    } catch (e) {
      return Failure(response: 'Failed to get location: $e');
    }
  }
}

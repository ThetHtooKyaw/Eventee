import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Object> requestLocationPermission() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Failure(
          response: 'Location services are disabled on this device.',
        );
      }

      permission = await Geolocator.checkPermission();
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

import 'package:eventee/core/services/location_service.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/view_models/base_view_model.dart';

class LocationViewModel extends BaseViewModel {
  // Dependencies
  final LocationService _locationService;
  LocationViewModel(this._locationService);

  // Use Cases
  Future<Map<String, String?>?> getCurrentLocation() async {
    setError(null);

    final response = await _locationService.requestLocationPermission();

    if (response is Failure) {
      setError(response.response.toString());
      return null;
    }

    final locationData = (response as Success).response as Map<String, dynamic>;

    return locationData.cast<String, String?>();
  }
}

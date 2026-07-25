import 'package:eventee/core/services/location_service.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/account/repo/account_service.dart';

class LocationViewModel extends BaseViewModel {
  // Dependencies
  final LocationService _locationService;
  final AccountService _accountService;

  LocationViewModel(this._locationService, this._accountService);

  // Use Cases
  Future<bool> requestLocationPermission() async {
    setError(null);

    final response = await _locationService.requestLocationPermission();

    if (response is Failure) {
      setError(response.response.toString());
      return false;
    }

    final address = (response as Success).response as String;
    await _accountService.updateAddress(newAddress: address);

    return true;
  }
}

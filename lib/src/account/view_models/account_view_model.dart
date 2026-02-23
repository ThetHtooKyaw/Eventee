import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';

class AccountViewModel extends BaseViewModel {
  // Dependencies
  final AuthService _authService;
  AccountViewModel(this._authService);

  // Variables
  AppUser? _user;

  // Getters
  AppUser? get user => _user;

  // Use Cases
  Future<void> loadUser() async {
    setScreenLoading(true);
    setError(null);

    final response = await _authService.getUser();

    if (response is Success) {
      _user = response.response as AppUser;
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setScreenLoading(false);
  }

  Future<void> logoutUser() async {
    setScreenLoading(true);
    final response = await _authService.logoutUser();

    if (response is Failure) {
      setError(response.response.toString());
    }

    setScreenLoading(false);
  }
}

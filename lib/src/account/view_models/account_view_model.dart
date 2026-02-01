import 'package:flutter/foundation.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/account/models/account_error.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';

class AccountViewModel extends ChangeNotifier {
  // Dependencies
  final AuthService _authService;
  AccountViewModel(this._authService);

  // Variables
  AppUser? _user;
  bool _loading = false;
  AccountError? _accountError;

  // Getters
  AppUser? get user => _user;
  bool get loading => _loading;
  AccountError? get accountError => _accountError;

  // Setters
  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setAccountError(AccountError accountError) {
    _accountError = accountError;
    notifyListeners();
  }

  void clearAccountError() {
    _accountError = null;
    notifyListeners();
  }

  // Use Cases
  Future<void> logoutUser() async {
    setLoading(true);
    final response = await _authService.logoutUser();

    if (response is Failure) {
      setAccountError(AccountError(message: response.response.toString()));
    }

    setLoading(false);
  }

  Future<void> loadUser() async {
    setLoading(true);
    clearAccountError();

    final response = await _authService.getUser();

    if (response is Success) {
      _user = response.response as AppUser;
    } else if (response is Failure) {
      setAccountError(AccountError(message: response.response.toString()));
    }

    setLoading(false);
  }
}

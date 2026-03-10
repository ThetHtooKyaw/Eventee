import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:eventee/src/auth/models/app_user.dart';

class AccountViewModel extends BaseViewModel {
  // Dependencies
  final AccountService _accountService;
  AccountViewModel(this._accountService);

  // Variables
  AppUser? _user;

  // Getters
  AppUser? get user => _user;

  // Use Cases

  Future<void> loadUser({bool forceRefresh = false}) async {
    if (_user != null && !forceRefresh) return;

    setScreenLoading(true);
    setError(null);

    final response = await _accountService.getUser();

    if (response is Success) {
      _user = response.response as AppUser;
      notifyListeners();
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setScreenLoading(false);
  }

  Future<void> logoutUser() async {
    setScreenLoading(true);
    final response = await _accountService.logoutUser();

    if (response is Success) {
      _user = null;
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setScreenLoading(false);
  }
}

import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:eventee/src/auth/models/app_user.dart';

class AccountViewModel extends BaseViewModel {
  // Dependencies
  final AccountService _accountService;
  AccountViewModel(this._accountService) {
    loadUser();
  }

  // Variables
  AppUser? _user;

  // Getters
  AppUser? get user => _user;

  // Use Cases
  Future<void> loadUser({bool forceRefresh = false}) async {
    if (_user != null && !forceRefresh) return;

    startScreenLoading();

    final response = await _accountService.getUser();

    if (response is Failure) {
      stopScreenLoadingWithErrorMessage(response.response.toString());
      return;
    }

    _user = (response as Success).response as AppUser;
    setScreenLoading(false);
  }

  Future<bool> logoutUser() async {
    startActionLoading();

    final response = await _accountService.logoutUser();

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    _user = null;
    setActionLoading(false);
    return true;
  }
}

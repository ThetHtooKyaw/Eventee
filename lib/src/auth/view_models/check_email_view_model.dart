import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/view_models/base_view_model.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';

class CheckEmailViewModel extends BaseViewModel {
  // Dependencies
  final AuthService _authService;
  CheckEmailViewModel(this._authService);

  // Use Cases
  Future<void> openEmailApp() async {
    startActionLoading();

    final response = await _authService.openEmailApp();

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return;
    }

    setActionLoading(false);
  }
}

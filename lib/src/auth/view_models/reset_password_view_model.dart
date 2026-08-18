import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/view_models/base_view_model.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:flutter/material.dart';

class ResetPasswordViewModel extends BaseViewModel {
  // Dependencies
  final AuthService _authService;
  ResetPasswordViewModel(this._authService);

  // Controllers
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Use Cases
  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<bool> resetPassword({required String oobCode}) async {
    startActionLoading();

    final response = await _authService.resetPassword(
      oobCode: oobCode,
      newPassword: passwordController.text.trim(),
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    stopActionLoadingWithSuccessMessage(
      (response as Success).response.toString(),
    );
    return true;
  }
}

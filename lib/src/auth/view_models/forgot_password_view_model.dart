import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/view_models/base_view_model.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  // Dependencies
  final AuthService _authService;
  ForgotPasswordViewModel(this._authService);

  // Controllers
  final emailController = TextEditingController();

  // Use Cases
  Future<bool> resetPassword() async {
    startActionLoading();

    final response = await _authService.resetPassword(
      email: emailController.text.trim(),
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

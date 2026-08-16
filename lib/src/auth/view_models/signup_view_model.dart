import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/view_models/base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';

class SignUpViewModel extends BaseViewModel {
  // Dependencies
  final AuthService _authService;
  SignUpViewModel(this._authService);

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Variables
  bool _tosPrivacyAccepted = false;

  // Getters
  bool get tosPrivacyAccepted => _tosPrivacyAccepted;

  // Setters
  void setTosPrivacyAccepted(bool value) {
    _tosPrivacyAccepted = value;
    notifyListeners();
  }

  // Use Cases
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> createUser() async {
    startActionLoading();

    final response = await _authService.signUpUser(
      username: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      tosPrivacyAccepted: _tosPrivacyAccepted,
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

  Future<Object?> signUpWithGoogle() async {
    startActionLoading();

    final response = await _authService.authenticateWithGoogle();

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return null;
    }

    setActionLoading(false);
    return (response as Success).response;
  }
}

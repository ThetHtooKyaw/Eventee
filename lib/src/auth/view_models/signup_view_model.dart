import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
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

  // Use Cases
  Future<bool> createUser() async {
    setActionLoading(true);
    setError(null);

    final response = await _authService.signUpUser(
      username: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setActionLoading(false);
    return true;
  }

  Future<Object?> signUpWithGoogle() async {
    setActionLoading(true);
    setError(null);

    final response = await _authService.authenticateWithGoogle();

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return null;
    }

    setActionLoading(false);
    return (response as Success).response;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

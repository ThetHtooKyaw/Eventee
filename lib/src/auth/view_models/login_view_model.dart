import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends BaseViewModel {
  // Dependencies
  final AuthService _authService;
  LoginViewModel(this._authService);

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Use Cases
  Future<bool> loginUser() async {
    setActionLoading(true);
    setError(null);

    final response = await _authService.loginUser(
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

  Future<Object?> signInWithGoogle() async {
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

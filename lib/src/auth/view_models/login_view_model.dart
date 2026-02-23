import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:eventee/src/auth/view_models/params/login_params.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends BaseViewModel {
  // Dependencies
  final AuthService _authService;
  LoginViewModel(this._authService);

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variables
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Getters
  GlobalKey<FormState> get formKey => _formKey;

  // Use Cases
  Future<void> loginUser({required LoginParams params}) async {
    setActionLoading(true);
    setError(null);

    final response = await _authService.loginUser(params: params);

    if (response is Failure) {
      setError(response.response.toString());
    }
    setActionLoading(false);
  }

  Future<void> signInWithGoogle() async {
    setActionLoading(true);
    setError(null);

    final response = await _authService.signUpWithGoogle();

    if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

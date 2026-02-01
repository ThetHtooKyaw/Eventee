import 'package:eventee/src/auth/view_models/params/signup_params.dart';
import 'package:flutter/material.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/src/auth/models/auth_error.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';

class SignUpViewModel extends ChangeNotifier {
  // Dependencies
  final AuthService _authService;
  SignUpViewModel(this._authService);

  // Variables
  bool _loading = false;
  AuthError? _authError;

  // Getters
  bool get loading => _loading;
  AuthError? get authError => _authError;

  // Setters
  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setAuthError(AuthError authError) {
    _authError = authError;
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  // Use Cases
  Future<void> createUser({required SignUpParams params}) async {
    setLoading(true);
    clearAuthError();

    final response = await _authService.createUser(params: params);

    if (response is Failure) {
      setAuthError(AuthError(message: response.response.toString()));
    }

    setLoading(false);
  }

  Future<void> signUpWithGoogle() async {
    setLoading(true);
    clearAuthError();

    final response = await _authService.signUpWithGoogle();

    if (response is Failure) {
      setAuthError(AuthError(message: response.response.toString()));
    }

    setLoading(false);
  }
}

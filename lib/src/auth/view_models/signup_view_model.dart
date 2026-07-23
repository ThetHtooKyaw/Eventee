import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/auth/view_models/params/signup_params.dart';
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
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();

  // Variables
  final _formKey = GlobalKey<FormState>();

  // Getters
  GlobalKey<FormState> get formKey => _formKey;

  // Use Cases
  Future<bool> createUser() async {
    setActionLoading(true);
    setError(null);

    final params = SignUpParams(
      username: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      address: addressController.text.trim(),
    );

    final response = await _authService.createUser(params: params);

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setActionLoading(false);
    return true;
  }

  Future<bool> signUpWithGoogle() async {
    setActionLoading(true);
    setError(null);

    final response = await _authService.signUpWithGoogle();

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setActionLoading(false);
    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

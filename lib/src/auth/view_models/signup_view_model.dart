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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Variables
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Getters
  GlobalKey<FormState> get formKey => _formKey;

  // Use Cases
  Future<void> createUser() async {
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
    }

    setActionLoading(false);
  }

  Future<void> signUpWithGoogle() async {
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
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

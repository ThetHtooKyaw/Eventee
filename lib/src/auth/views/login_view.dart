import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/utils/bottom_nav_bar.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/onboarding/views/onboarding_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/src/auth/view_models/login_view_model.dart';
import 'package:eventee/src/auth/views/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<LoginViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.errorMessage != null && mounted) {
      AppSnackbars.showErrorSnackbar(context, _viewModel.errorMessage!);
      _viewModel.setError(null);
    }
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      final success = await _viewModel.loginUser();

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      }
    }
  }

  Future<void> loginWithGoogle() async {
    final result = await _viewModel.signInWithGoogle();

    if (!mounted) return;

    if (result != null && result is Map) {
      final isNewUser = result['isNewUser'] as bool;
      if (isNewUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingView()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LoginViewModel>();

    return Scaffold(
      body: Selector<LoginViewModel, bool>(
        selector: (_, vm) => vm.isActionLoading,
        builder: (context, isActionLoading, child) {
          return Stack(
            children: [
              child!,
              if (isActionLoading) LoadingOverlayColumn(message: 'Logging in'),
            ],
          );
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
              vertical: AppFormat.secondaryPadding,
            ),
            child: Column(
              children: [
                // Title
                Text(
                  "Eventee",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 24),

                // TextFields
                _buildLoginForm(vm),
                SizedBox(height: 40),

                // Login Button
                ElevatedButton(
                  onPressed: () => login(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text("Login"),
                ),
                SizedBox(height: 10),

                Divider(),
                const SizedBox(height: 10),

                // Google Login Button
                ElevatedButton(
                  onPressed: () => loginWithGoogle(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 20),
                      Text("Sign in with Google"),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Sign-Up Link
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpView(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(LoginViewModel vm) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Email TextField
          TextFormField(
            controller: vm.emailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(labelText: "Email"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }

              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }

              return null;
            },
          ),
          SizedBox(height: 16),

          // Password TextField
          TextFormField(
            controller: vm.passwordController,
            keyboardType: TextInputType.text,
            obscureText: _obscurePassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.lightPrimary,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}

import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/bottom_nav_bar.dart';
import 'package:eventee/core/widgets/loading_column.dart';
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
  bool _obscurePassword = true;

  Future<void> login() async {
    final vm = context.read<LoginViewModel>();

    if (vm.formKey.currentState!.validate()) {
      final success = await vm.loginUser();

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else {
        AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
      }
    }
  }

  Future<void> loginWithGoogle() async {
    final vm = context.read<LoginViewModel>();
    final success = await vm.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    } else {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          Center(
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
                  SizedBox(height: 20),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: vm.isActionLoading ? null : () => login(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Login"),
                  ),
                  SizedBox(height: 20),

                  Divider(),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: vm.isActionLoading
                        ? null
                        : () => loginWithGoogle(),
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

          if (vm.isActionLoading) LoadingOverlayColumn(message: 'Logging in'),
        ],
      ),
    );
  }

  Widget _buildLoginForm(LoginViewModel vm) {
    return Form(
      key: vm.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: vm.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Email"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              } else if (value.contains('@') == false) {
                return "Please enter a valid email";
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: vm.passwordController,
            keyboardType: TextInputType.text,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your password";
              } else if (value.length < 6) {
                return "Password must be at least 6 characters";
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}

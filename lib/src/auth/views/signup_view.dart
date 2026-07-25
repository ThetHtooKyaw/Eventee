import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/bottom_nav_bar.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/src/auth/view_models/signup_view_model.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> signUp() async {
    final vm = context.read<SignUpViewModel>();

    if (vm.formKey.currentState!.validate()) {
      final success = await vm
          .createUser(); 

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      } else {
        AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
      }
    }
  }

  Future<void> signUpWithGoogle() async {
    final vm = context.read<SignUpViewModel>();

    final success = await vm.signUpWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );
    } else {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.watch<SignUpViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppFormat.primaryPadding,
                vertical: AppFormat.secondaryPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text("Unlock the Future of", style: t.textTheme.displayLarge),
                  const SizedBox(height: 10),
                  Text(
                    "Event Booking App",
                    style: t.textTheme.displayLarge?.copyWith(
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Discover, book, and experience unforgettable moments effortlessly",
                    textAlign: TextAlign.center,
                    style: t.textTheme.titleSmall?.copyWith(
                      color: AppColor.placeholder,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Text Fields
                  _buildSignUpForm(vm),

                  ElevatedButton(
                    onPressed: vm.isActionLoading ? null : () => signUp(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                    ),
                    child: Text("Sign up"),
                  ),
                  SizedBox(height: 20),

                  Divider(),
                  const SizedBox(height: 20),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: vm.isActionLoading
                        ? null
                        : () => signUpWithGoogle(),
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
                        Text("Sign up with Google"),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          if (vm.isActionLoading)
            LoadingOverlayColumn(message: 'Creating your account'),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(SignUpViewModel vm) {
    return Form(
      key: vm.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: vm.nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(labelText: "Name"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: vm.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Email"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
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
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              if (value.trim().length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          TextFormField(
            controller: vm.confirmPasswordController,
            keyboardType: TextInputType.text,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your confirm password';
              }
              if (value != vm.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

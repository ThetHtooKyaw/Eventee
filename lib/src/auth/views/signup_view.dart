import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/core/utils/bottom_nav_bar.dart';
import 'package:eventee/src/onboarding/views/onboarding_view.dart';
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
  late final SignUpViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SignUpViewModel>();
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

  Future<void> signUp() async {
    final vm = context.read<SignUpViewModel>();

    if (_formKey.currentState!.validate()) {
      final success = await vm.createUser();

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingView()),
        );
      }
    }
  }

  Future<void> signUpWithGoogle() async {
    final vm = context.read<SignUpViewModel>();
    final result = await vm.signUpWithGoogle();

    if (!mounted) return;

    if (result != null && result is Map) {
      final isNewUser = result['isNewUser'] as bool;
      if (isNewUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingView()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
          (r) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.read<SignUpViewModel>();

    return Scaffold(
      body: Selector<SignUpViewModel, bool>(
        selector: (_, vm) => vm.isActionLoading,
        builder: (context, isActionLoading, child) {
          return Stack(
            children: [
              child!,
              if (isActionLoading)
                LoadingOverlayColumn(message: 'Creating your account'),
            ],
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppFormat.primaryPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  "Unlock the Future of \nEvent Booking App",
                  textAlign: TextAlign.center,
                  style: t.textTheme.displayLarge,
                ),

                const SizedBox(height: 20),

                Text(
                  "Discover, book, and experience unforgettable moments effortlessly",
                  textAlign: TextAlign.center,
                  style: t.textTheme.bodyLarge?.copyWith(
                    color: AppColor.textPlaceholder,
                  ),
                ),
                const SizedBox(height: 60),

                // Text Fields
                _buildSignUpForm(vm),
                SizedBox(height: 40),

                // Action Buttons
                Selector<SignUpViewModel, bool>(
                  selector: (_, vm) => vm.isActionLoading,
                  builder: (context, isActionLoading, child) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: isActionLoading ? null : () => signUp(),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 60),
                          ),
                          child: Text("Sign up"),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: isActionLoading
                              ? null
                              : () => signUpWithGoogle(),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 60),
                          ),
                          child: child,
                        ),
                      ],
                    );
                  },
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
      ),
    );
  }

  Widget _buildSignUpForm(SignUpViewModel vm) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextField(
            controller: vm.nameController,
            keyboardType: TextInputType.name,
            labelText: "Name",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.length < 4) {
                return 'Name must be at least 4 characters long';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          _buildTextField(
            controller: vm.emailController,
            keyboardType: TextInputType.emailAddress,
            labelText: "Email",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          _buildPasswordField(
            controller: vm.passwordController,
            labelText: "Password",
            obscureIconState: obscurePassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              if (value.trim().length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
            onObscureIconTap: () {
              setState(() => obscurePassword = !obscurePassword);
            },
          ),
          SizedBox(height: 16),

          _buildPasswordField(
            controller: vm.confirmPasswordController,
            labelText: "Confirm Password",
            obscureIconState: obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your confirm password';
              }
              if (value != vm.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            onObscureIconTap: () {
              setState(() => obscureConfirmPassword = !obscureConfirmPassword);
            },
          ),
        ],
      ),
    );
  }

  TextFormField _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    required bool obscureIconState,
    required VoidCallback onObscureIconTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      obscureText: obscureIconState,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          onPressed: onObscureIconTap,
          icon: Icon(
            obscureIconState ? Icons.visibility_off : Icons.visibility,
            color: AppColor.lightPrimary,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String labelText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: labelText),
      validator: validator,
    );
  }
}

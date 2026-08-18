import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/core/utils/bottom_nav_bar.dart';
import 'package:eventee/src/auth/widgets/custom_divider.dart';
import 'package:eventee/src/auth/widgets/custom_password_textfield.dart';
import 'package:eventee/src/onboarding/views/onboarding_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/src/settings/views/privacy_policy_view.dart';
import 'package:eventee/src/settings/views/terms_of_service_view.dart';
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
    if (_formKey.currentState!.validate()) {
      final success = await _viewModel.createUser();

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
    final result = await _viewModel.signUpWithGoogle();

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
    final theme = Theme.of(context);
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
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: 20),

                // Subtitle
                Text(
                  "Discover, book, and experience unforgettable moments effortlessly",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColor.textPlaceholder,
                  ),
                ),
                const SizedBox(height: 60),

                // Text Fields
                _buildSignUpForm(vm),
                const SizedBox(height: 40),

                // Login Buttons
                ElevatedButton(
                  onPressed: () => signUp(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),
                  ),
                  child: Text("Sign up"),
                ),
                SizedBox(height: 20),

                CustomDivider(),
                const SizedBox(height: 20),

                // Google Sign-Up Button
                ElevatedButton(
                  onPressed: () => signUpWithGoogle(),
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

                // Login Link
                RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: "Login",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                        ),
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
          // Name TextField
          TextFormField(
            controller: vm.nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(labelText: 'Name'),
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

          // Email TextField
          TextFormField(
            controller: vm.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
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
          CustomPasswordTextfield(
            controller: vm.passwordController,
            labelText: "Password",
            obscureIconState: obscurePassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters long.';
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Password must contain an uppercase letter.';
              }
              if (!value.contains(RegExp(r'[a-z]'))) {
                return 'Password must contain a lowercase letter.';
              }
              if (!value.contains(RegExp(r'[0-9]'))) {
                return 'Password must contain a number.';
              }
              if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                return 'Password must contain a special character.';
              }

              return null;
            },
            onObscureIconTap: () {
              setState(() => obscurePassword = !obscurePassword);
            },
          ),
          SizedBox(height: 16),

          // Confirm Password TextField
          CustomPasswordTextfield(
            controller: vm.confirmPasswordController,
            labelText: "Confirm Password",
            obscureIconState: obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
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
          const SizedBox(height: 20),

          // Terms and Conditions
          _buildTermsAndConditions(Theme.of(context)),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(ThemeData theme) {
    return Selector<SignUpViewModel, bool>(
      selector: (_, vm) => vm.tosPrivacyAccepted,
      builder: (context, tosPrivacyAccepted, _) {
        return FormField<bool>(
          initialValue: tosPrivacyAccepted,
          validator: (value) {
            if (value == false) {
              return 'Please agree to the terms to continue.';
            }
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: tosPrivacyAccepted,
                        onChanged: (value) {
                          _viewModel.setTosPrivacyAccepted(value ?? false);
                          state.didChange(value ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text:
                              'By creating an account, I acknowledge that I have read and agree to the ',
                          style: theme.textTheme.bodySmall,
                          children: [
                            _buildClickableTextSpan('Terms of Service', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TermsOfServiceView(),
                                ),
                              );
                            }),
                            const TextSpan(
                              text:
                                  ' and consent to the processing of my data as outlined in the ',
                            ),
                            _buildClickableTextSpan('Privacy Policy', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyView(),
                                ),
                              );
                            }),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                    child: Text(
                      state.errorText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  TextSpan _buildClickableTextSpan(String text, VoidCallback onTap) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }
}

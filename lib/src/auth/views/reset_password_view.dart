import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:eventee/src/auth/view_models/reset_password_view_model.dart';
import 'package:eventee/src/auth/widgets/custom_password_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordView extends StatefulWidget {
  final String oobCode;

  const ResetPasswordView({super.key, required this.oobCode});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late final ResetPasswordViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ResetPasswordViewModel>();
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
    } else if (_viewModel.successMessage != null && mounted) {
      AppSnackbars.showSuccessSnackbar(context, _viewModel.successMessage!);
      _viewModel.setSuccess(null);
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await _viewModel.resetPassword(oobCode: widget.oobCode);

      if (success && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ResetPasswordViewModel>();

    return Selector<ResetPasswordViewModel, bool>(
      selector: (_, vm) => vm.isActionLoading,
      builder: (context, isActionLoading, child) {
        return Stack(
          children: [
            child!,
            if (isActionLoading)
              LoadingOverlayColumn(message: 'Resetting password'),
          ],
        );
      },
      child: Scaffold(
        appBar: ViewAppbar(title: 'Create New Password'),
        body: Padding(
          padding: const EdgeInsets.all(AppFormat.primaryPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your new password must be different from previously used passwords.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                // Password TextField
                Text('Password', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),

                CustomPasswordTextfield(
                  controller: vm.passwordController,
                  labelText: "Enter password",
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
                Text(
                  'Confirm Password',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),

                CustomPasswordTextfield(
                  controller: vm.confirmPasswordController,
                  labelText: "Enter confirm password",
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
                    setState(
                      () => obscureConfirmPassword = !obscureConfirmPassword,
                    );
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Text('Reset Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

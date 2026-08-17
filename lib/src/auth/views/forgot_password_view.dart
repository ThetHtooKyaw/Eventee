import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:eventee/src/auth/view_models/forgot_password_view_model.dart';
import 'package:eventee/src/auth/views/check_email_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final ForgotPasswordViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ForgotPasswordViewModel>();
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
      final success = await _viewModel.resetPassword();

      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CheckEmailView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ForgotPasswordViewModel>();

    return Scaffold(
      appBar: ViewAppbar(title: 'Reset Password'),
      body: Padding(
        padding: const EdgeInsets.all(AppFormat.primaryPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Text(
                'Enter your email associated with your account and we will send you an email with instructions to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Email TextField
              Text(
                'Email Address',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: vm.emailController,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: "Enter email address",
                ),
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
              const SizedBox(height: 20),

              // Reset Password Button
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
    );
  }
}

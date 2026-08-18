import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/auth/view_models/check_email_view_model.dart';
import 'package:eventee/src/auth/view_models/forgot_password_view_model.dart';
import 'package:eventee/src/auth/views/login_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckEmailView extends StatefulWidget {
  const CheckEmailView({super.key});

  @override
  State<CheckEmailView> createState() => _CheckEmailViewState();
}

class _CheckEmailViewState extends State<CheckEmailView> {
  late final CheckEmailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<CheckEmailViewModel>();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Selector<ForgotPasswordViewModel, bool>(
        selector: (_, vm) => vm.isActionLoading,
        builder: (context, isActionLoading, child) {
          return Stack(
            children: [
              child!,
              if (isActionLoading)
                LoadingOverlayColumn(message: 'Opening email app'),
            ],
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(
                        AppFormat.primaryBorderRadius,
                      ),
                    ),
                    child: Icon(
                      Icons.mark_as_unread_rounded,
                      size: 60,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Check your mail',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'We have sent a password recover\ninstructions to your email.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),

                  // Helper Text
                  Text(
                    'If the app doesn\'t open your inbox, please switch to it manually to find our email.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  // Action Button
                  ElevatedButton(
                    onPressed: () async => await context
                        .read<CheckEmailViewModel>()
                        .openEmailApp(),
                    style: ElevatedButton.styleFrom(minimumSize: Size(200, 60)),
                    child: const Text('Open Email App'),
                  ),
                  const SizedBox(height: 20),

                  // Skip Button
                  TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                      (route) => false,
                    ),
                    child: Text(
                      'Skip, I\'ll confirm later',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),

                  const Text(
                    'Did not receive the email? Check your spam filter,',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                  ),

                  // Try Another Email Button
                  RichText(
                    text: TextSpan(
                      text: "or ",
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: "try another email address",
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

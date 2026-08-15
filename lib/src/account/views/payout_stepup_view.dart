import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:eventee/src/account/view_models/payout_stepup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayoutStepupView extends StatefulWidget {
  const PayoutStepupView({super.key});

  @override
  State<PayoutStepupView> createState() => _PayoutStepupViewState();
}

class _PayoutStepupViewState extends State<PayoutStepupView> {
  late final PayoutStepupViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PayoutStepupViewModel>();
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
    final vm = context.watch<PayoutStepupViewModel>();

    return Selector<PayoutStepupViewModel, bool>(
      selector: (_, vm) => vm.isActionLoading,
      builder: (context, isActionLoading, child) {
        return Stack(
          children: [
            child!,
            if (isActionLoading)
              LoadingOverlayColumn(message: 'Navigating to Stripe onboarding'),
          ],
        );
      },
      child: Scaffold(
        appBar: ViewAppbar(title: 'Secure Payout Setup'),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppFormat.secondaryPadding,
            horizontal: AppFormat.primaryPadding,
          ),
          child: Column(
            children: [
              Text(
                'Connect your account to start accepting customer payments and tracking your revenue',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),

              _buildInfoRow(
                icon: Icons.percent,
                title: 'Platform Service Fee: 7%',
                description:
                    ' is retained by our platform to cover operational costs, hosting, and customer support.',
              ),
              const SizedBox(height: 20),

              _buildInfoRow(
                icon: Icons.credit_card,
                title: 'Payment Processing',
                description:
                    ' Stripe securely processes all credit cards, protects you from fraud, and deposits your remaining earnings directly into your bank account.',
              ),
              const SizedBox(height: 20),

              _buildInfoRow(
                icon: Icons.security,
                title: 'Data Privacy',
                description:
                    ' We never see, store, or have access to your bank account numbers or tax information.',
              ),
              const Spacer(),

              ElevatedButton.icon(
                onPressed: () => vm.connectWithStripe(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                ),
                label: const Text('Connect with Stripe'),
              ),
              const SizedBox(height: 10),

              Text(
                "You will be redirected to Stripe's secure portal to quickly create or link an account.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

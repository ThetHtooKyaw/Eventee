import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:eventee/src/account/view_models/billing_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillingView extends StatefulWidget {
  const BillingView({super.key});

  @override
  State<BillingView> createState() => _BillingViewState();
}

class _BillingViewState extends State<BillingView> {
  late final BillingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BillingViewModel>();
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
    return Scaffold(
      appBar: ViewAppbar(title: 'Billing'),
      body: Selector<BillingViewModel, bool>(
        selector: (_, vm) => vm.isActionLoading,
        builder: (context, isActionLoading, child) {
          return Padding(
            padding: const EdgeInsets.all(AppFormat.primaryPadding),
            child: ElevatedButton.icon(
              onPressed: isActionLoading
                  ? null
                  : () => context.read<BillingViewModel>().connectWithStripe(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              label: const Text('Connect with Stripe'),
            ),
          );
        },
      ),
    );
  }
}

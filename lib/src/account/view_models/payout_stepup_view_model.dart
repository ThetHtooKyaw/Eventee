import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/view_models/base_view_model.dart';
import 'package:eventee/src/account/repo/payout_stepup_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PayoutStepupViewModel extends BaseViewModel {
  // Dependencies
  final PayoutStepupService _payoutStepupService;
  PayoutStepupViewModel(this._payoutStepupService);

  // Use Cases
  Future<void> connectWithStripe() async {
    startActionLoading();

    final response = await _payoutStepupService.createStripeAccount();

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return;
    }

    final url = (response as Success).response;
    final uri = Uri.parse(url as String);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_self');
      setActionLoading(false);
    }
  }
}

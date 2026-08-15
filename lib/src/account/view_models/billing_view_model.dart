import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/view_models/base_view_model.dart';
import 'package:eventee/src/account/repo/billing_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingViewModel extends BaseViewModel {
  // Dependencies
  final BillingService _billingService;
  BillingViewModel(this._billingService);

  // Use Cases
  Future<void> connectWithStripe() async {
    startActionLoading();

    final response = await _billingService.createStripeAccount();

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

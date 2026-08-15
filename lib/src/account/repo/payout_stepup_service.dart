import 'package:cloud_functions/cloud_functions.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:flutter/foundation.dart';

class PayoutStepupService {
  final _functions = FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  Future<Object> createStripeAccount() async {
    try {
      final callable = _functions.httpsCallable('createStripeAccount');
      final result = await callable.call();

      final data = result.data as Map<String, dynamic>;
      final url = data['url'];

      if (url == null) {
        return Failure(response: 'Failed to get onboarding URL.');
      }

      return Success(response: url);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud function error (${e.code}): ${e.message}');

      return Failure(
        response: 'Cloud function error (${e.code}): ${e.message}',
      );
    } catch (e) {
      return Failure(response: 'System error: $e.');
    }
  }
}

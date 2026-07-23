import 'package:flutter/foundation.dart';

// This is a private helper function to check if a ChangeNotifier has been disposed.
// It works by exploiting the fact that calling `notifyListeners` on a disposed
// notifier will throw a FlutterError. We catch this error to determine the state.
bool _isDisposed(ChangeNotifier notifier) {
  try {
    // This is a no-op that will throw if the object is disposed.
    notifier.toString();
    return false;
  } catch (_) {
    return true;
  }
}

class BaseViewModel extends ChangeNotifier {
  bool _isScreenloading = false;
  bool _isActionLoading = false;
  String? _successMessage;
  String? _errorMessage;

  bool get isScreenLoading => _isScreenloading;
  bool get isActionLoading => _isActionLoading;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  bool get mounted => !_isDisposed(this);

  void setScreenLoading(bool value) {
    _isScreenloading = value;
    if (mounted) notifyListeners();
  }

  void setActionLoading(bool value) {
    _isActionLoading = value;
    if (mounted) notifyListeners();
  }

  void setSuccess(String? message) {
    _successMessage = message;
    if (mounted) notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    if (mounted) notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isScreenloading = false;
  bool _isActionLoading = false;
  String? _successMessage;
  String? _errorMessage;

  bool get isScreenLoading => _isScreenloading;
  bool get isActionLoading => _isActionLoading;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  void setScreenLoading(bool value) {
    _isScreenloading = value;
    notifyListeners();
  }

  void setActionLoading(bool value) {
    _isActionLoading = value;
    notifyListeners();
  }

  void setSuccess(String? message) {
    _successMessage = message;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isScreenloading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  bool get isScreenLoading => _isScreenloading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  void setScreenLoading(bool value) {
    _isScreenloading = value;
    notifyListeners();
  }

  void setActionLoading(bool value) {
    _isActionLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}

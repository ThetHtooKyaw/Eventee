import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class BaseViewModel extends ChangeNotifier {
  // State Variables
  bool _isScreenloading = false;
  bool _isActionLoading = false;
  String? _successMessage;
  String? _errorMessage;

  // Getters
  bool get isScreenLoading => _isScreenloading;
  bool get isActionLoading => _isActionLoading;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  void safeNotifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  // Use Cases
  // Screen Loading
  void setScreenLoading(bool value) {
    _isScreenloading = value;
    safeNotifyListeners();
  }

  void startScreenLoading() {
    _isScreenloading = true;
    _errorMessage = null;
    _successMessage = null;
    safeNotifyListeners();
  }

  void stopScreenLoadingWithErrorMessage(String? message) {
    _isScreenloading = false;
    _errorMessage = message;
    safeNotifyListeners();
  }

  // Action Loading
  void setActionLoading(bool value) {
    _isActionLoading = value;
    safeNotifyListeners();
  }

  void startActionLoading() {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    safeNotifyListeners();
  }

  void stopActionLoadingWithSuccessMessage(String? message) {
    _isActionLoading = false;
    _successMessage = message;
    safeNotifyListeners();
  }

  void stopActionLoadingWithErrorMessage(String? message) {
    _isActionLoading = false;
    _errorMessage = message;
    safeNotifyListeners();
  }

  void setSuccess(String? message) {
    _successMessage = message;
    safeNotifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    safeNotifyListeners();
  }
}

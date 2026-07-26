import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/core/view_models/location_view_model.dart';
import 'package:flutter/material.dart';

class OnboardingViewModel extends BaseViewModel {
  // Dependencies
  final LocationViewModel _locationViewModel;
  OnboardingViewModel(this._locationViewModel);

  // Controllers
  final pageController = PageController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final dobCOntroller = TextEditingController();

  // Variables
  int currentPage = 0;
  int totalPages = 4;
  String? _country;
  String? _state;
  String? _city;

  // Getters
  String? get country => _country;
  String? get state => _state;
  String? get city => _city;

  // Setters
  void setCountry(String? value) {
    _country = value;
    notifyListeners();
  }

  void setState(String? value) {
    _state = value;
    notifyListeners();
  }

  void setCity(String? value) {
    _city = value;
    notifyListeners();
  }

  // Use Cases
  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dobCOntroller.dispose();
  }

  void nextPage() {
    if (currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {}
  }

  void previousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> initialLocation() async {
    setError(null);
    setScreenLoading(true);

    final locationData = await _locationViewModel.getCurrentLocation();

    if (locationData == null) {
      setError(_locationViewModel.errorMessage);
      setScreenLoading(false);
      return false;
    }

    _country = locationData['country'];
    _state = locationData['state'];
    _city = locationData['city'];
    notifyListeners();
    setScreenLoading(false);
    return true;
  }
}

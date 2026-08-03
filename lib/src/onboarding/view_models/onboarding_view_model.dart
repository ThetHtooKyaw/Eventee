import 'dart:io';

import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/core/view_models/location_view_model.dart';
import 'package:eventee/src/onboarding/repo/onboarding_service.dart';
import 'package:flutter/material.dart';

class OnboardingViewModel extends BaseViewModel {
  // Dependencies
  final LocationViewModel _locationViewModel;
  final OnboardingService _onboardingService;
  OnboardingViewModel(this._locationViewModel, this._onboardingService) {
    initializeProfileAvatar();
    initialLocation();
  }

  // Controllers
  final pageController = PageController();
  final addressController = TextEditingController();
  final dobCOntroller = TextEditingController();

  // Variables
  int currentPage = 0;
  int totalPages = 4;
  String? _currentProfileAvatar;
  File? _profileAvatar;
  DateTime _selectedBirthday = DateTime(
    DateTime.now().year - 18,
    DateTime.now().month,
    DateTime.now().day,
  );
  String? _phoneNumber;
  String? _country;
  String? _state;
  String? _city;

  // Getters
  String? get currentProfileAvatar => _currentProfileAvatar;
  File? get profileAvatar => _profileAvatar;
  String? get phoneNumber => _phoneNumber;
  String? get country => _country;
  String? get state => _state;
  String? get city => _city;

  // Setters
  void setCurrentPage(int index) {
    currentPage = index;
    notifyListeners();
  }

  void setBirthday(DateTime date) {
    _selectedBirthday = date;
    notifyListeners();
  }

  void setPhoneNo(String? number) {
    _phoneNumber = number;
    notifyListeners();
  }

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
    addressController.dispose();
    dobCOntroller.dispose();
  }

  Future<void> initializeProfileAvatar() async {
    startScreenLoading();

    final response = await _onboardingService.fetchCurrentProfileAvatar();

    if (response is Failure) {
      stopScreenLoadingWithErrorMessage(response.response.toString());
      return;
    }

    _currentProfileAvatar = (response as Success).response as String;
    setScreenLoading(false);
  }

  Future<void> initialLocation() async {
    startScreenLoading();

    final locationData = await _locationViewModel.getCurrentLocation();

    if (locationData == null) {
      stopScreenLoadingWithErrorMessage(_locationViewModel.errorMessage);
      return;
    }

    if (mounted) {
      _country = locationData['country'];
      _state = locationData['state'];
      _city = locationData['city'];
      setScreenLoading(false);
    }
  }

  ImageProvider? getProfileAvatar() {
    if (_currentProfileAvatar != null && _currentProfileAvatar!.isNotEmpty) {
      return NetworkImage(_currentProfileAvatar!);
    }

    if (_profileAvatar != null) {
      return FileImage(_profileAvatar!);
    }

    return null;
  }

  Future<void> pickProfileAvatar() async {
    startActionLoading();

    final response = await _onboardingService.pickProfileAvatar();

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return;
    }

    _profileAvatar = (response as Success).response as File?;
    _currentProfileAvatar = null;
    setActionLoading(false);
  }

  Future<bool> submitOnboardingData() async {
    startActionLoading();

    final response = await _onboardingService.submitOnboardingData(
      profileFile: _profileAvatar,
      existingPhotoUrl: _currentProfileAvatar,
      dateOfBirth: _selectedBirthday,
      phoneNumber: _phoneNumber!,
      address: formatAddress(),
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    setActionLoading(false);
    return true;
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String formatAddress() {
    final parts = [
      addressController.text.trim(),
      _city,
      _state,
      _country,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return parts;
  }
}

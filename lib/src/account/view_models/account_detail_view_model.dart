import 'dart:io';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountDetailViewModel extends BaseViewModel {
  // Dependencies
  final AccountService _accountService;
  AccountDetailViewModel(this._accountService);

  // Controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  // Variables
  File? _profileAvatar;
  DateTime? _selectedBirthday = DateTime(
    DateTime.now().year - 18,
    DateTime.now().month,
    DateTime.now().day,
  );
  String? _phoneNumber;
  String? _country;
  String? _state;
  String? _city;

  // Getters
  File? get profileAvatar => _profileAvatar;
  DateTime? get selectedBirthday => _selectedBirthday;
  String? get phoneNumber => _phoneNumber;
  String? get country => _country;
  String? get state => _state;
  String? get city => _city;

  // Setters
  void setBirthday(DateTime? date) {
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
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void initialize(AppUser user) {
    nameController.text = user.username;
    addressController.text = user.address;
    _selectedBirthday = user.dateOfBirth;
    notifyListeners();
  }

  ImageProvider? getProfileAvatar(String photoUrl) {
    if (_profileAvatar != null) {
      return FileImage(_profileAvatar!);
    }
    if (photoUrl.isNotEmpty) {
      return NetworkImage(photoUrl);
    }

    return null;
  }

  Future<bool> pickProfileAvatar() async {
    startActionLoading();

    final response = await _accountService.pickProfileAvatar();

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    _profileAvatar = (response as Success).response as File?;
    setActionLoading(false);
    return true;
  }

  Future<bool> updateProfileAvatar() async {
    startActionLoading();

    if (profileAvatar == null) {
      stopActionLoadingWithErrorMessage('No profile avatar selected.');
      return false;
    }

    final response = await _accountService.updateProfileAvatar(
      profileFile: profileAvatar!,
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    stopActionLoadingWithSuccessMessage(
      (response as Success).response.toString(),
    );
    return true;
  }

  Future<bool> updateUsername() async {
    startActionLoading();

    final response = await _accountService.updateUsername(
      newUsername: nameController.text.trim(),
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    stopActionLoadingWithSuccessMessage(
      (response as Success).response.toString(),
    );
    return true;
  }

  Future<bool> updatePhoneNumber() async {
    startActionLoading();

    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      stopActionLoadingWithErrorMessage('Phone number cannot be empty.');
      return false;
    }

    final response = await _accountService.updatePhoneNumber(
      newPhoneNumber: _phoneNumber!,
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    stopActionLoadingWithSuccessMessage(
      (response as Success).response.toString(),
    );
    return true;
  }

  Future<bool> updateDateOfBirth() async {
    startActionLoading();

    final response = await _accountService.updateDateOfBirth(
      newDateOfBirth: _selectedBirthday!,
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    stopActionLoadingWithSuccessMessage(
      (response as Success).response.toString(),
    );
    setActionLoading(false);
    return true;
  }

  Future<bool> updateAddress() async {
    startActionLoading();

    if (formatAddress().isEmpty) {
      stopActionLoadingWithErrorMessage('Address cannot be empty.');
      return false;
    }

    final response = await _accountService.updateAddress(
      newAddress: formatAddress(),
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    stopActionLoadingWithSuccessMessage(
      (response as Success).response.toString(),
    );
    return true;
  }

  String formatBirthday(DateTime birthDate) {
    return DateFormat('dd/MM/yyyy').format(birthDate);
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

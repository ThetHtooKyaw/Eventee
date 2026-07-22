import 'dart:io';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountDetailViewModel extends BaseViewModel {
  // Dependencies
  final AccountService _accountService;
  AccountDetailViewModel(this._accountService);

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phNoController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Variables
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _profileImage;
  DateTime? _selectedBirthday;
  String? _country;
  String? _state;
  String? _city;

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  File? get profileImage => _profileImage;
  DateTime? get selectedBirthday => _selectedBirthday;
  String? get country => _country;
  String? get state => _state;
  String? get city => _city;

  // Setters
  void setBirthday(DateTime? date) {
    _selectedBirthday = date;
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
    phNoController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> pickProfileImage() async {
    setActionLoading(true);
    setError(null);

    final response = await _accountService.pickProfileImage();

    if (response is Success) {
      _profileImage = response.response as File;
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  Future<void> updateProfileImage() async {
    setActionLoading(true);
    setError(null);

    final response = await _accountService.updateProfileImage(
      profileFile: _profileImage!,
    );

    if (response is Success) {
      setSuccess(response.response.toString());
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  Future<void> updateUsername() async {
    setActionLoading(true);
    setError(null);

    final response = await _accountService.updateUsername(
      newUsername: nameController.text.trim(),
    );

    if (response is Success) {
      setSuccess(response.response.toString());
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  Future<void> updatePhoneNumber() async {
    setActionLoading(true);
    setError(null);

    final response = await _accountService.updatePhoneNumber(
      newPhoneNumber: phNoController.text.trim(),
    );

    if (response is Success) {
      setSuccess(response.response.toString());
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  Future<void> updateDateOfBirth() async {
    setActionLoading(true);
    setError(null);

    final response = await _accountService.updateDateOfBirth(
      newDateOfBirth: _selectedBirthday!,
    );

    if (response is Success) {
      setSuccess(response.response.toString());
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  Future<void> updateLocation() async {
    setActionLoading(true);
    setError(null);

    final response = await _accountService.updateLocation(
      newLocation: formatLocation(),
    );

    if (response is Success) {
      setSuccess(response.response.toString());
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  String formatBirthday(DateTime birthDate) {
    return DateFormat('dd/MM/yyyy').format(birthDate);
  }

  String formatLocation() {
    final parts = [
      locationController.text.trim(),
      _city,
      _state,
      _country,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return parts;
  }

  ImageProvider? getAvatarImage(String? photoUrl) {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      return NetworkImage(photoUrl);
    }

    return null;
  }
}

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
  final phNoController = TextEditingController();
  final addressController = TextEditingController();

  // Variables
  final _formKey = GlobalKey<FormState>();
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
    addressController.dispose();
    super.dispose();
  }

  void initialize(AppUser user) {
    nameController.text = user.username;
    phNoController.text = user.phoneNumber;
    addressController.text = user.address;
    _selectedBirthday = user.dateOfBirth;
    notifyListeners();
  }

  ImageProvider? getAvatarImage(String photoUrl) {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
    if (photoUrl.isNotEmpty) {
      return NetworkImage(photoUrl);
    }

    return null;
  }

  Future<bool> pickProfileImage() async {
    setActionLoading(true);
    setError(null);

    final response = await _accountService.pickProfileImage();

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    _profileImage = (response as Success).response as File?;
    setActionLoading(false);
    return true;
  }

  Future<bool> updateProfileImage() async {
    setActionLoading(true);
    setError(null);
    setSuccess(null);

    if (profileImage == null) {
      setError('Please pick an image first.');
      setActionLoading(false);
      return false;
    }

    final response = await _accountService.updateProfileImage(
      profileFile: profileImage!,
    );

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setSuccess((response as Success).response.toString());
    setActionLoading(false);
    return true;
  }

  Future<bool> updateUsername() async {
    setActionLoading(true);
    setError(null);
    setSuccess(null);

    final response = await _accountService.updateUsername(
      newUsername: nameController.text.trim(),
    );

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setSuccess((response as Success).response.toString());
    setActionLoading(false);
    return true;
  }

  Future<bool> updatePhoneNumber() async {
    setActionLoading(true);
    setError(null);
    setSuccess(null);

    final response = await _accountService.updatePhoneNumber(
      newPhoneNumber: phNoController.text.trim(),
    );

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setSuccess((response as Success).response.toString());
    setActionLoading(false);
    return true;
  }

  Future<bool> updateDateOfBirth() async {
    setActionLoading(true);
    setError(null);
    setSuccess(null);

    final response = await _accountService.updateDateOfBirth(
      newDateOfBirth: _selectedBirthday!,
    );

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setSuccess((response as Success).response.toString());
    setActionLoading(false);
    return true;
  }

  Future<bool> updateAddress() async {
    setActionLoading(true);
    setError(null);
    setSuccess(null);

    final response = await _accountService.updateAddress(
      newAddress: formatAddress(),
    );

    if (response is Failure) {
      setError(response.response.toString());
      setActionLoading(false);
      return false;
    }

    setSuccess((response as Success).response.toString());
    setActionLoading(false);
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

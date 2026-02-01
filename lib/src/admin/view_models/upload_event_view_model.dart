import 'dart:io';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/admin/model/admin_error.dart';
import 'package:eventee/src/admin/repo/admin_service.dart';
import 'package:eventee/src/admin/view_models/params/upload_event_params.dart';
import 'package:flutter/material.dart';

class UploadEventViewModel extends ChangeNotifier {
  // Dependencies
  final AdminService _adminService;
  UploadEventViewModel(this._adminService);

  // Variables
  bool _loading = false;
  AdminError? _adminError;
  File? _eventImage;

  // Getters
  bool get loading => _loading;
  AdminError? get adminError => _adminError;
  File? get eventImage => _eventImage;

  // Setters
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void setAdminError(AdminError adminError) {
    _adminError = adminError;
    notifyListeners();
  }

  void clearAdminError() {
    _adminError = null;
    notifyListeners();
  }

  // Use Cases
  Future<void> pickEventImage() async {
    setLoading(true);
    clearAdminError();

    final response = await _adminService.pickEventImage();

    if (response is Success) {
      _eventImage = response.response as File;
    } else if (response is Failure) {
      setAdminError(AdminError(message: response.response.toString()));
    }

    setLoading(false);
  }

  Future<void> uploadEventDetail({required UploadEventParams params}) async {
    setLoading(true);
    clearAdminError();

    final response = await _adminService.uploadEventDetail(params: params);

    if (response is Failure) {
      setAdminError(AdminError(message: response.response.toString()));
    }

    setLoading(false);
  }

  void clearEventImage() {
    _eventImage = null;
    notifyListeners();
  }
}

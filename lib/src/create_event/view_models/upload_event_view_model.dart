import 'dart:io';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/create_event/repo/admin_service.dart';
import 'package:eventee/src/create_event/view_models/params/upload_event_params.dart';
import 'package:flutter/material.dart';

class UploadEventViewModel extends BaseViewModel {
  // Dependencies
  final AdminService _adminService;
  UploadEventViewModel(this._adminService);

  // Controllers
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  final TextEditingController ticketPriceController = TextEditingController();
  final TextEditingController eventDetailController = TextEditingController();

  // Variables
  File? _eventImage;

  // Getters
  File? get eventImage => _eventImage;

  // Use Cases
  @override
  void dispose() {
    eventNameController.dispose();
    eventDateController.dispose();
    eventLocationController.dispose();
    ticketPriceController.dispose();
    eventDetailController.dispose();
    super.dispose();
  }

  Future<void> pickEventImage() async {
    setActionLoading(true);
    setError(null);

    final response = await _adminService.pickEventImage();

    if (response is Success) {
      _eventImage = response.response as File;
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  Future<void> uploadEventDetail({required UploadEventParams params}) async {
    setActionLoading(true);
    setError(null);

    final response = await _adminService.uploadEventDetail(params: params);

    if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }

  void clearEventImage() {
    _eventImage = null;
    notifyListeners();
  }
}

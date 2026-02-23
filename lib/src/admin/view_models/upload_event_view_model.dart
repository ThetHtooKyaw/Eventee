import 'dart:io';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/admin/repo/admin_service.dart';
import 'package:eventee/src/admin/view_models/params/upload_event_params.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> categories = ['Music', 'Sport', 'Art', 'Food'];
  File? _eventImage;
  String? _selectedCategory;

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  File? get eventImage => _eventImage;
  String? get selectedCategory => _selectedCategory;

  // Setters
  void setCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

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

  void resetForm() {
    eventNameController.clear();
    eventDateController.clear();
    eventLocationController.clear();
    ticketPriceController.clear();
    eventDetailController.clear();
    _selectedCategory = null;
    _eventImage = null;
    notifyListeners();
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

  Future<void> uploadEventDetail() async {
    setActionLoading(true);
    setError(null);

    final params = UploadEventParams(
      eventImage: _eventImage!,
      eventName: eventNameController.text.trim(),
      eventDate: DateFormat('dd/MM/yyyy').parse(eventDateController.text),
      eventLocation: eventLocationController.text.trim(),
      ticketPrice: double.parse(ticketPriceController.text),
      eventDetail: eventDetailController.text.trim(),
      eventCategory: _selectedCategory!,
    );

    final response = await _adminService.uploadEventDetail(params: params);

    if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }
}

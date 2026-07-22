import 'dart:io';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/create_event/repo/admin_service.dart';
import 'package:eventee/src/create_event/view_models/params/upload_event_params.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEventViewModel extends BaseViewModel {
  // Dependencies
  final AdminService _adminService;
  CreateEventViewModel(this._adminService);

  // Controllers
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventStartTimeController =
      TextEditingController();
  final TextEditingController eventEndTimeController = TextEditingController();
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
    eventStartTimeController.dispose();
    eventEndTimeController.dispose();
    eventLocationController.dispose();
    ticketPriceController.dispose();
    eventDetailController.dispose();
    super.dispose();
  }

  void resetForm() {
    eventNameController.clear();
    eventDateController.clear();
    eventStartTimeController.clear();
    eventEndTimeController.clear();
    eventLocationController.clear();
    ticketPriceController.clear();
    eventDetailController.clear();
    _selectedCategory = null;
    _eventImage = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
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

  Future<void> pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd MMM, yyyy').format(pickedDate);

      eventDateController.text = formattedDate;
      notifyListeners();
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final dt = DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute);

      String formattedTime = DateFormat('hh:mm a').format(dt);

      eventStartTimeController.text = formattedTime;
      notifyListeners();
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final dt = DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute);

      String formattedTime = DateFormat('hh:mm a').format(dt);

      eventEndTimeController.text = formattedTime;
      notifyListeners();
    }
  }

  Future<void> uploadEventDetail() async {
    setActionLoading(true);
    setError(null);

    final baseDate = DateFormat('dd MMM, yyyy').parse(eventDateController.text);
    final baseStartTime = DateFormat(
      'hh:mm a',
    ).parse(eventStartTimeController.text);
    final baseEndTime = DateFormat(
      'hh:mm a',
    ).parse(eventEndTimeController.text);

    final startTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      baseStartTime.hour,
      baseStartTime.minute,
    );

    final endTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      baseEndTime.hour,
      baseEndTime.minute,
    );

    final params = UploadEventParams(
      imageUrl: _eventImage!,
      title: eventNameController.text.trim(),
      location: eventLocationController.text.trim(),
      date: baseDate,
      startTime: startTime,
      endTime: endTime,
      price: double.parse(ticketPriceController.text),
      description: eventDetailController.text.trim(),
      category: _selectedCategory!,
    );

    final response = await _adminService.uploadEventDetail(params: params);

    if (response is Failure) {
      setError(response.response.toString());
    }

    setActionLoading(false);
  }
}

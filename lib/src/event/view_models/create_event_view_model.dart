import 'dart:io';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/view_models/base_view_model.dart';
import 'package:eventee/src/event/repo/create_event_service.dart';
import 'package:eventee/src/event/view_models/params/create_event_params.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEventViewModel extends BaseViewModel {
  // Dependencies
  final CreateEventService _createEventService;
  CreateEventViewModel(this._createEventService);

  // Controllers
  GlobalKey<FormState>? formKey;

  final eventNameController = TextEditingController();
  final organizationNameController = TextEditingController();
  final organizerNameController = TextEditingController();
  final dateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final locationController = TextEditingController();
  final ticketPriceController = TextEditingController();
  final eventDetailController = TextEditingController();

  // Variables

  final List<String> categories = ['Music', 'Sport', 'Art', 'Food'];
  File? _eventImage;
  String? _selectedCategory;
  DateTime? _selectedDate;
  DateTime? _startTime;
  DateTime? _endTime;

  // Getters
  File? get eventImage => _eventImage;
  String? get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  // Setters
  void setFormKey(GlobalKey<FormState> key) {
    formKey = key;
  }

  void setCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  // Use Cases
  @override
  void dispose() {
    eventNameController.dispose();
    organizationNameController.dispose();
    organizerNameController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    locationController.dispose();
    ticketPriceController.dispose();
    eventDetailController.dispose();
    super.dispose();
  }

  void resetForm() {
    eventNameController.clear();
    organizationNameController.clear();
    organizerNameController.clear();
    dateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    locationController.clear();
    ticketPriceController.clear();
    eventDetailController.clear();
    _selectedCategory = null;
    _eventImage = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    startActionLoading();

    final response = await _createEventService.pickEventImage();

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return;
    }

    _eventImage = (response as Success).response as File;
    notifyListeners();
    setActionLoading(false);
  }

  void onDatePicked(DateTime pickedDate) {
    _selectedDate = pickedDate;
    String formattedDate = DateFormat('dd MMM, yyyy').format(pickedDate);
    dateController.text = formattedDate;

    if (_startTime != null) {
      _startTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }

    if (_endTime != null) {
      _endTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    formKey?.currentState?.validate();
    notifyListeners();
  }

  void onStartTimePicked(TimeOfDay pickedTime) {
    final date = _selectedDate ?? DateTime.now();
    _startTime = DateTime(
      date.year,
      date.month,
      date.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    String formattedTime = DateFormat('hh:mm a').format(_startTime!);
    startTimeController.text = formattedTime;
    formKey?.currentState?.validate();
    notifyListeners();
  }

  void onEndTimePicked(TimeOfDay pickedTime) {
    final date = _selectedDate ?? DateTime.now();
    _endTime = DateTime(
      date.year,
      date.month,
      date.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    String formattedTime = DateFormat('hh:mm a').format(_endTime!);
    endTimeController.text = formattedTime;
    formKey?.currentState?.validate();
    notifyListeners();
  }

  Future<bool> uploadEventDetail() async {
    startActionLoading();

    final baseDate = DateFormat('dd MMM, yyyy').parse(dateController.text);
    final baseStartTime = DateFormat('hh:mm a').parse(startTimeController.text);
    final baseEndTime = DateFormat('hh:mm a').parse(endTimeController.text);

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

    final params = CreateEventParams(
      imageUrl: _eventImage!,
      title: eventNameController.text.trim(),
      organization: organizationNameController.text.trim(),
      organizer: organizerNameController.text.trim(),
      location: locationController.text.trim(),
      date: baseDate,
      startTime: startTime,
      endTime: endTime,
      price: double.parse(ticketPriceController.text),
      description: eventDetailController.text.trim(),
      category: _selectedCategory!,
    );

    final response = await _createEventService.uploadEventDetail(
      params: params,
    );

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return false;
    }

    resetForm();
    stopActionLoadingWithSuccessMessage(
      (response as Success).response.toString(),
    );
    return true;
  }
}

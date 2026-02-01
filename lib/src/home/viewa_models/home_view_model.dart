import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/admin/model/event.dart';
import 'package:eventee/src/admin/repo/admin_service.dart';
import 'package:eventee/src/home/models/home_error.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  // Dependencies
  final AdminService _adminService;
  HomeViewModel(this._adminService);

  // Variables
  bool _loading = false;
  HomeError? _homeError;
  Stream<List<EventModel>>? _eventStream;
  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];

  // Getters
  bool get loading => _loading;
  HomeError? get homeError => _homeError;
  Stream<List<EventModel>>? get eventStream => _eventStream;
  List<EventModel> get events => _events;
  List<EventModel> get filteredEvents => _filteredEvents;

  // Setters
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void setHomeError(HomeError homeError) {
    _homeError = homeError;
    notifyListeners();
  }

  void clearHomeError() {
    _homeError = null;
    notifyListeners();
  }

  // Use Cases
  Future<void> fetchAllEvents() async {
    setLoading(true);
    clearHomeError();

    final response = await _adminService.fetchAllEvents();

    if (response is Success) {
      final stream = response.response as Stream<List<EventModel>>;
      _eventStream = stream.map((eventList) {
        _events = eventList;
        _filteredEvents = eventList;
        return eventList;
      });
      notifyListeners();
    } else if (response is Failure) {
      setHomeError(HomeError(message: response.response.toString()));
    }

    setLoading(false);
  }

  void filterEvents(String query) {
    if (query.isEmpty) {
      _filteredEvents = _events;
    } else {
      _filteredEvents = _events.where((event) {
        return event.eventName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}

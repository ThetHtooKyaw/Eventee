import 'dart:async';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/create_event/model/event.dart';
import 'package:eventee/src/create_event/repo/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeViewModel extends BaseViewModel {
  // Dependencies
  final AdminService _adminService;
  HomeViewModel(this._adminService);

  // Controllers
  final TextEditingController searchController = TextEditingController();

  // Variables
  final List<(IconData icon, String label)> _categories = const [
    (Icons.list_alt, 'All'),
    (Icons.music_note, 'Music'),
    (Icons.sports_basketball, 'Sport'),
    (Icons.brush, 'Art'),
    (Icons.fastfood, 'Food'),
  ];
  StreamSubscription? _eventSubscription;
  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  String _selectedCategory = 'All';

  // Getters
  List<(IconData icon, String label)> get categories => _categories;
  List<EventModel> get events => _filteredEvents;
  String get selectedCategory => _selectedCategory;

  // Use Cases
  Future<void> fetchAllEvents() async {
    setScreenLoading(true);
    setError(null);

    final response = await _adminService.fetchAllEvents();

    if (response is Success) {
      final stream = response.response as Stream<List<EventModel>>;

      await _eventSubscription?.cancel();
      _eventSubscription = stream.listen(
        (eventList) {
          _events = eventList;

          if (_selectedCategory == 'All') {
            _filteredEvents = eventList;
          } else {
            filterByCategory(_selectedCategory);
          }

          if (isScreenLoading) {
            setScreenLoading(false);
          } else {
            notifyListeners();
          }
        },
        onError: (error) {
          setError(error.toString());
          if (isScreenLoading) setScreenLoading(false);
        },
      );
    } else if (response is Failure) {
      setError(response.response.toString());
      setScreenLoading(false);
    }
  }

  void filterEvents(String query) {
    if (query.isEmpty) {
      _filteredEvents = _events;
    } else {
      _filteredEvents = _events.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;

    if (category == 'All') {
      _filteredEvents = List.from(_events);
      notifyListeners();
    } else {
      _filteredEvents = _events.where((event) {
        return event.category.toLowerCase() == category.toLowerCase();
      }).toList();
    }

    notifyListeners();
  }

  String formatDateMonthDay(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }
}

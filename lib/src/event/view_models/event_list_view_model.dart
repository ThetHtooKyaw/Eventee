import 'dart:async';

import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/event/model/event.dart';
import 'package:eventee/src/event/repo/event_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum EventSortOrder { none, priceAscending, priceDescending }

class EventListViewModel extends BaseViewModel {
  // Dependencies
  final EventService _eventService;
  EventListViewModel(this._eventService);

  // Controllers
  final searchController = TextEditingController();
  final locationFilterController = TextEditingController();

  // Variables
  final List<String> _categories = const [
    'All',
    'Music',
    'Sport',
    'Art',
    'Food',
  ];
  StreamSubscription? _eventSubscription;
  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  String _selectedCategory = 'All';
  EventSortOrder _sortOrder = EventSortOrder.none;
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _maxPrice = 10000;

  // Getters
  List<String> get categories => _categories;
  EventSortOrder get sortOrder => _sortOrder;
  List<EventModel> get events => _filteredEvents;
  String get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;
  double get maxPrice => _maxPrice;

  // Use Cases
  @override
  void dispose() {
    _eventSubscription?.cancel();
    searchController.dispose();
    locationFilterController.dispose();
    super.dispose();
  }

  Future<void> fetchAllEvents() async {
    setScreenLoading(true);
    setError(null);

    final response = await _eventService.fetchAllEvents();

    if (response is Success) {
      final stream = response.response as Stream<List<EventModel>>;

      await _eventSubscription?.cancel();
      _eventSubscription = stream.listen(
        (eventList) {
          _events = eventList;

          _maxPrice = eventList.fold(
            0.0,
            (max, event) => event.price > max ? event.price : max,
          );
          if (_maxPrice == 0) _maxPrice = 10000;

          double newStart = _priceRange.start.clamp(0.0, _maxPrice);
          double newEnd = _priceRange.end.clamp(0.0, _maxPrice);
          _priceRange = RangeValues(newStart, newEnd);

          applyFilters();

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

  void applyFilters() {
    List<EventModel> results = List.from(_events);

    // Search filter
    _filteredEvents = results;
    if (searchController.text.isNotEmpty) {
      _filteredEvents = _filteredEvents
          .where(
            (event) => event.title.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    // Location filter
    if (locationFilterController.text.isNotEmpty) {
      results = results
          .where(
            (event) => event.location.toLowerCase().contains(
              locationFilterController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      results = results
          .where(
            (event) =>
                event.category.toLowerCase() == _selectedCategory.toLowerCase(),
          )
          .toList();
    }

    // Apply sorting
    if (_sortOrder == EventSortOrder.priceAscending) {
      _filteredEvents.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOrder == EventSortOrder.priceDescending) {
      _filteredEvents.sort((a, b) => b.price.compareTo(a.price));
    }

    // Price filter
    results = results
        .where(
          (event) =>
              event.price >= _priceRange.start &&
              event.price <= _priceRange.end,
        )
        .toList();

    notifyListeners();
  }

  void filterEvents(String query) {
    applyFilters();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortOrder(EventSortOrder order) {
    _sortOrder = order;
    applyFilters();
  }

  void setPriceRange(RangeValues values) {
    _priceRange = values;
    notifyListeners();
  }

  void resetFilters() {
    locationFilterController.clear();
    _selectedCategory = 'All';
    _sortOrder = EventSortOrder.none;
    _priceRange = RangeValues(0, _maxPrice);
    applyFilters();
    notifyListeners();
  }

  String formatDateMonthDay(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}

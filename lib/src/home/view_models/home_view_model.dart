import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/event/model/event.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';

class HomeViewModel extends BaseViewModel {
  // Dependencies
  final EventListViewModel _eventListViewModel;
  HomeViewModel(this._eventListViewModel);

  // Getters
  List<EventModel> get events => _eventListViewModel.events;

  // Use Cases
}

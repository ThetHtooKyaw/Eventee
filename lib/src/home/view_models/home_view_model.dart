import 'package:eventee/core/view_models/base_view_model.dart';
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

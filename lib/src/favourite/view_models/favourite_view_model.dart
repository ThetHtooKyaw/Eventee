import 'dart:async';

import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/event/model/event.dart';
import 'package:eventee/src/favourite/services/favourite_service.dart';

class FavouriteViewModel extends BaseViewModel {
  // Dependencies
  final FavouriteService _favouriteService;
  FavouriteViewModel(this._favouriteService) {
    fetchFavouritedEventId();
  }

  // Variables
  StreamSubscription? _favouriteSubscription;
  Set<String> _favouritedEventIds = {};

  // Getters
  Set<String> get favouritedEventIds => _favouritedEventIds;

  // User Cases
  @override
  void dispose() {
    _favouriteSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchFavouritedEventId() async {
    startScreenLoading();

    final response = await _favouriteService.fetchFavouritedEventId();

    if (response is Success) {
      final stream = response.response as Stream<Set<String>>;

      await _favouriteSubscription?.cancel();
      _favouriteSubscription = stream.listen(
        (favouritedEventIdList) {
          _favouritedEventIds = favouritedEventIdList;
          setScreenLoading(false);
        },
        onError: (error) {
          stopScreenLoadingWithErrorMessage(error.toString());
        },
      );
    } else if (response is Failure) {
      stopScreenLoadingWithErrorMessage(response.response.toString());
      return;
    }
  }

  Future<void> toggleFavourite(EventModel event) async {
    startActionLoading();

    final isCurrentlyFavourited = _favouritedEventIds.contains(event.eventId);
    dynamic response;

    if (isCurrentlyFavourited) {
      response = await _favouriteService.removeFavourite(event.eventId);
    } else {
      response = await _favouriteService.addFavourite(event.eventId);
    }

    if (response is Failure) {
      stopActionLoadingWithErrorMessage(response.response.toString());
      return;
    }

    setActionLoading(false);
  }
}

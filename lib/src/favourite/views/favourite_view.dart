import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/src/event/repo/booked_event_service.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';
import 'package:eventee/src/event/view_models/event_details_view_model.dart';
import 'package:eventee/src/event/views/event_details_view.dart';
import 'package:eventee/src/event/widgets/event_card.dart';
import 'package:eventee/src/event/widgets/event_list_skeleton.dart';
import 'package:eventee/src/favourite/view_models/favourite_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouriteView extends StatefulWidget {
  const FavouriteView({super.key});

  @override
  State<FavouriteView> createState() => _FavouriteViewState();
}

class _FavouriteViewState extends State<FavouriteView> {
  late final FavouriteViewModel _viwModel;

  @override
  void initState() {
    super.initState();
    _viwModel = context.read<FavouriteViewModel>();
    _viwModel.addListener(_onViewModelChanged);
    _viwModel.fetchFavouritedEventId();
  }

  @override
  void dispose() {
    _viwModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viwModel.errorMessage != null && mounted) {
      AppSnackbars.showErrorSnackbar(context, _viwModel.errorMessage!);
      _viwModel.setError(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.colorScheme.onPrimary,
        title: Text('Favourite', style: theme.textTheme.titleSmall),
      ),
      body: Selector<FavouriteViewModel, bool>(
        selector: (_, vm) => vm.isScreenLoading,
        builder: (context, isScreenLoading, child) {
          if (isScreenLoading) {
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: AppFormat.secondaryPadding,
                horizontal: AppFormat.primaryPadding,
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemCount: 6,
              itemBuilder: (context, index) {
                return EventListSkeleton(cardWidth: double.infinity);
              },
            );
          }
          return child!;
        },
        child: Consumer2<FavouriteViewModel, EventListViewModel>(
          builder: (context, favouriteVm, eventListVm, child) {
            final favouritedEvents = eventListVm.allEvents
                .where(
                  (event) =>
                      favouriteVm.favouritedEventIds.contains(event.eventId),
                )
                .toList();

            if (favouritedEvents.isEmpty) {
              return Center(
                child: Text(
                  'No favourited events found!',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: AppFormat.secondaryPadding,
                horizontal: AppFormat.primaryPadding,
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemCount: favouritedEvents.length,
              itemBuilder: (context, index) {
                final favouritedEvent = favouritedEvents[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => EventDetailsViewModel(
                            context.read<BookedEventService>(),
                          ),
                          child: EventDetailsView(event: favouritedEvent),
                        ),
                      ),
                    );
                  },
                  child: EventCard(
                    event: favouritedEvent,
                    cardWidth: double.infinity,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

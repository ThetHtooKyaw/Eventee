import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/view_appbar.dart';
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
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Selector<FavouriteViewModel, String?>(
      selector: (_, vm) => vm.errorMessage,
      builder: (context, errorMessage, child) {
        if (errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbars.showErrorSnackbar(context, errorMessage);
            context.read<FavouriteViewModel>().setError(null);
          });
        }
        
        return Scaffold(
          appBar: ViewAppbar(title: 'Favourite'),
          body: Consumer2<FavouriteViewModel, EventListViewModel>(
            builder: (context, favouriteVm, eventListVm, child) {
              final isScreenLoading = favouriteVm.isScreenLoading;
              final favouritedEvents = eventListVm.allEvents
                  .where(
                    (event) =>
                        favouriteVm.favouritedEventIds.contains(event.eventId),
                  )
                  .toList();

              if (favouritedEvents.isEmpty && !isScreenLoading) {
                return Center(
                  child: Text(
                    'No favourited events found!',
                    style: t.textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(
                  vertical: AppFormat.secondaryPadding,
                  horizontal: AppFormat.primaryPadding,
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemCount: isScreenLoading ? 6 : favouritedEvents.length,
                itemBuilder: (context, index) {
                  if (isScreenLoading) {
                    return EventListSkeleton(cardWidth: double.infinity);
                  }

                  final favouritedEvent = favouritedEvents[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (context) => EventDetailsViewModel(
                              context.read<BookiedEventService>(),
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
        );
      },
    );
  }
}

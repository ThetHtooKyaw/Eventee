import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/app_error.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/event/repo/booked_event_service.dart';
import 'package:eventee/src/event/view_models/event_details_view_model.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';
import 'package:eventee/src/event/model/event.dart';
import 'package:eventee/src/event/views/event_details_view.dart';
import 'package:eventee/src/event/views/event_list_view.dart';
import 'package:eventee/src/event/widgets/event_card.dart';
import 'package:eventee/src/event/widgets/event_list_skeleton.dart';
import 'package:eventee/src/home/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AccountViewModel>().loadUser();
      context
          .read<EventListViewModel>()
          .fetchAllEvents(); // Trigger fetch from central VM
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final eventListVM = context.watch<EventListViewModel>();

    return Scaffold(
      backgroundColor: AppColor.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background Color
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColor.primary,
                  ),

                  // Header
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppFormat.secondaryPadding,
                        horizontal: AppFormat.primaryPadding,
                      ),
                      child: _buildHeader(t),
                    ),
                  ),

                  // Search Bar
                  Positioned(
                    bottom: 1,
                    right: AppFormat.primaryPadding,
                    left: AppFormat.primaryPadding,
                    child: _buildSearchBar(
                      context,
                      eventListVM,
                    ), // Pass EventListViewModel
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppFormat.primaryPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  SectionTitle(
                    title: 'Upcoming Events',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventListView(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Event List
                  SizedBox(
                    height: 310,
                    child: Selector<EventListViewModel, String?>(
                      // Watch EventListViewModel for errors
                      selector: (_, vm) =>
                          vm.errorMessage, // Use EventListViewModel's error
                      builder: (context, errorMessage, child) {
                        if (errorMessage != null) {
                          return AppError(errorMessage: errorMessage);
                        }

                        return Selector<EventListViewModel, bool>(
                          // Watch EventListViewModel for loading
                          selector: (_, vm) => vm
                              .isScreenLoading, // Use EventListViewModel's loading state
                          builder: (context, isScreenLoading, child) {
                            return Selector<
                              EventListViewModel,
                              List<EventModel>
                            >(
                              // Watch EventListViewModel for events
                              selector: (_, vm) => vm
                                  .events, // Use EventListViewModel's filtered events
                              builder: (context, events, child) {
                                if (events.isEmpty && !isScreenLoading) {
                                  return Center(
                                    child: Text(
                                      'No upcoming events!',
                                      style: t.textTheme.bodyLarge,
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppFormat.primaryPadding,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: isScreenLoading
                                      ? 6
                                      : events.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 20),
                                  itemBuilder: (context, index) {
                                    if (isScreenLoading) {
                                      return EventListSkeleton();
                                    }

                                    final event = events[index];

                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChangeNotifierProvider<
                                                EventDetailsViewModel
                                              >(
                                                create: (context) =>
                                                    EventDetailsViewModel(
                                                      context
                                                          .read<
                                                            BookingService
                                                          >(),
                                                    ),
                                                child: EventDetailsView(
                                                  event: event,
                                                ),
                                              ),
                                        ),
                                      ),
                                      child: EventCard(event: event),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Location
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Location',
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColor.white,
                ),
              ),
              Selector<AccountViewModel, String>(
                selector: (_, vm) =>
                    vm.user?.shortAddress ?? 'Unknown Location',
                builder: (context, shortAddress, child) {
                  return Text(
                    shortAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.titleSmall?.copyWith(
                      color: AppColor.white,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // TODO: Implement Notification Feature
        // Notification
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none_outlined, size: 32),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, EventListViewModel eventListVM) {
    return TextField(
      controller: eventListVM.searchController,
      onSubmitted: (value) {
        eventListVM.filterEvents(value);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventListView()),
        );
      },
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColor.white,
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search, color: AppColor.primary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColor.primary, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColor.primary, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

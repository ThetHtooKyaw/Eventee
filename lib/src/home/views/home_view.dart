import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final EventListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<EventListViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.fetchAllEvents();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.errorMessage != null && mounted) {
      AppSnackbars.showErrorSnackbar(context, _viewModel.errorMessage!);
      _viewModel.setError(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<EventListViewModel>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: theme.brightness == Brightness.light
                ? const SystemUiOverlayStyle(
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                  )
                : const SystemUiOverlayStyle(
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                  ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background Color
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: theme.colorScheme.primary,
                  ),

                  // Header
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppFormat.secondaryPadding,
                        horizontal: AppFormat.primaryPadding,
                      ),
                      child: _buildHeader(theme),
                    ),
                  ),

                  // Search Bar
                  Positioned(
                    bottom: 1,
                    right: AppFormat.primaryPadding,
                    left: AppFormat.primaryPadding,
                    child: _buildSearchBar(
                      context,
                      vm,
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
                    child: Selector<EventListViewModel, bool>(
                      selector: (_, vm) => vm.isScreenLoading,
                      builder: (context, isScreenLoading, child) {
                        if (isScreenLoading) {
                          return ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppFormat.primaryPadding,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 20),
                            itemBuilder: (context, index) {
                              return EventListSkeleton();
                            },
                          );
                        }

                        return child!;
                      },
                      child: Selector<EventListViewModel, List<EventModel>>(
                        selector: (_, vm) => vm.events,
                        builder: (context, events, child) {
                          if (events.isEmpty) {
                            return Center(
                              child: Text(
                                'No upcoming events!',
                                style: theme.textTheme.bodyLarge,
                              ),
                            );
                          }

                          return ListView.separated(
                            clipBehavior: Clip.none,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppFormat.primaryPadding,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 20),
                            itemBuilder: (context, index) {
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
                                                    .read<BookedEventService>(),
                                              ),
                                          child: EventDetailsView(event: event),
                                        ),
                                  ),
                                ),
                                child: EventCard(event: event),
                              );
                            },
                          );
                        },
                      ),
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

  Widget _buildHeader(ThemeData theme) {
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
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

  Widget _buildSearchBar(BuildContext context, EventListViewModel vm) {
    return TextField(
      controller: vm.searchController,
      onSubmitted: (value) {
        vm.filterEvents(value);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventListView()),
        );
      },
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search, color: AppColor.lightPrimary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColor.lightPrimary, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColor.lightPrimary, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

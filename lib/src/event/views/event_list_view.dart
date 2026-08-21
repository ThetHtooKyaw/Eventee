import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/src/event/model/event.dart';
import 'package:eventee/src/event/repo/booked_event_service.dart';
import 'package:eventee/src/event/view_models/event_details_view_model.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';
import 'package:eventee/src/event/views/event_details_view.dart';
import 'package:eventee/src/event/widgets/event_card.dart';
import 'package:eventee/src/event/widgets/event_filter_sheet.dart';
import 'package:eventee/src/event/widgets/event_list_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventListView extends StatefulWidget {
  final bool autofocusSearch;
  const EventListView({super.key, this.autofocusSearch = false});

  @override
  State<EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  late final EventListViewModel _viewModel;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<EventListViewModel>();
    _viewModel.addListener(_onViewModelChanged);

    _searchFocusNode = FocusNode();
    if (widget.autofocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _searchFocusNode.dispose();
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
    final t = Theme.of(context);
    final vm = context.read<EventListViewModel>();

    return Scaffold(
      appBar: _buildAppBar(context, vm),
      body: Selector<EventListViewModel, bool>(
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
        child: Selector<EventListViewModel, List<EventModel>>(
          selector: (_, vm) => vm.events,
          builder: (context, events, child) {
            if (events.isEmpty) {
              return Center(
                child: Text('No events found!', style: t.textTheme.bodyLarge),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: AppFormat.secondaryPadding,
                horizontal: AppFormat.primaryPadding,
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<EventDetailsViewModel>(
                            create: (context) => EventDetailsViewModel(
                              context.read<BookedEventService>(),
                            ),
                            child: EventDetailsView(event: event),
                          ),
                    ),
                  ),
                  child: EventCard(event: event, cardWidth: double.infinity),
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    EventListViewModel vm,
  ) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      leadingWidth: 50,
      toolbarHeight: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppFormat.secondaryPadding),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 30),
        ),
      ),
      title: TextField(
        focusNode: _searchFocusNode,
        controller: vm.searchController,
        onChanged: (value) => vm.filterEvents(value),
        decoration: InputDecoration(
          hintText: 'Search events...',
          prefixIcon: Icon(Icons.search, color: AppColor.lightPrimary),
          suffixIcon: IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                enableDrag: false,
                builder: (_) {
                  return ChangeNotifierProvider.value(
                    value: vm,
                    child: const EventFilterSheet(),
                  );
                },
              );
            },
            icon: Icon(Icons.filter_list, color: AppColor.lightPrimary),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.lightPrimary, width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.lightPrimary, width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

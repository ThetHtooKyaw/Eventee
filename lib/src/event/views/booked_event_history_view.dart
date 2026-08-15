import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/src/event/model/event_history.dart';
import 'package:eventee/src/event/view_models/booked_event_history_view_model.dart';
import 'package:eventee/src/event/widgets/custom_icon_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/core/widgets/loading_column.dart';

class BookedEventHistoryView extends StatefulWidget {
  const BookedEventHistoryView({super.key});

  @override
  State<BookedEventHistoryView> createState() => _BookedEventHistoryViewState();
}

class _BookedEventHistoryViewState extends State<BookedEventHistoryView> {
  late final BookedEventHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BookedEventHistoryViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.fetchBookingHistory();
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
    final vm = context.read<BookedEventHistoryViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Bookings', style: theme.textTheme.titleSmall),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            indicatorColor: theme.colorScheme.primary,
            unselectedLabelColor: AppColor.textPlaceholder,
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),

        body: Selector<BookedEventHistoryViewModel, bool>(
          selector: (_, vm) => vm.isScreenLoading,
          builder: (context, isScreenLoading, child) {
            if (isScreenLoading) {
              return const LoadingColumn(message: 'Loading booking history');
            }

            return child!;
          },
          child: TabBarView(
            children: [
              Selector<BookedEventHistoryViewModel, List<EventHistoryModel>>(
                selector: (_, vm) => vm.activeEventList,
                builder: (context, activeEvents, child) {
                  return _buildBookingList(
                    vm,
                    activeEvents,
                    'No active bookings found!',
                  );
                },
              ),
              Selector<BookedEventHistoryViewModel, List<EventHistoryModel>>(
                selector: (_, vm) => vm.completedEventList,
                builder: (context, completedEvents, child) {
                  return _buildBookingList(
                    vm,
                    completedEvents,
                    'No completed bookings found!',
                  );
                },
              ),
              Selector<BookedEventHistoryViewModel, List<EventHistoryModel>>(
                selector: (_, vm) => vm.cancelledEventList,
                builder: (context, cancelledEvents, child) {
                  return _buildBookingList(
                    vm,
                    cancelledEvents,
                    'No cancelled bookings found!',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BookedEventHistoryViewModel vm,
    List<EventHistoryModel> bookings,
    String emptyMessage,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: Theme.of(context).textTheme.bodyLarge),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppFormat.primaryPadding),
      shrinkWrap: true,
      itemCount: bookings.length,
      separatorBuilder: (context, index) => SizedBox(height: 20),
      itemBuilder: (context, index) {
        EventHistoryModel event = bookings[index];

        final eventDate = vm.formatDate(event.date);
        final eventStartTime = vm.formatTime(event.startTime);
        final eventEndTime = vm.formatTime(event.endTime);

        return _buildBookedEventHistoryCard(
          event,
          eventDate,
          eventStartTime,
          eventEndTime,
        );
      },
    );
  }

  Widget _buildBookedEventHistoryCard(
    EventHistoryModel event,
    String eventDate,
    String eventStartTime,
    String eventEndTime,
  ) {
    final theme = Theme.of(context);

    return CouponCard(
      height: 200,
      curveAxis: Axis.vertical,
      backgroundColor: theme.colorScheme.primary,
      borderRadius: AppFormat.primaryPadding,
      curveRadius: AppFormat.primaryPadding,
      curvePosition: 240,
      firstChild: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppFormat.secondaryPadding,
          horizontal: AppFormat.primaryPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Location
            CustomIconLabel(
              icon: Icons.location_on_outlined,
              child: Text(
                event.location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Timeline
            CustomIconLabel(
              icon: Icons.timer_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time
                  Text(
                    '$eventStartTime - $eventEndTime',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Date
                  Text(
                    eventDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Quantity
                Text(
                  'Quantity:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: AppFormat.secondaryPadding,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.quantity.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Status
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: AppFormat.secondaryPadding,
                  ),
                  decoration: BoxDecoration(
                    color: event.status == 'active'
                        ? Colors.green
                        : theme.colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.status.toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColor.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      secondChild: Padding(
        padding: const EdgeInsets.all(AppFormat.secondaryPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppFormat.secondaryBorderRadius,
              ),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) =>
                    SkeletonWidget(height: 100, width: 100),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(
                vertical: 4,
                horizontal: AppFormat.secondaryPadding,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(
                  AppFormat.secondaryBorderRadius,
                ),
              ),
              child: Text(
                '฿${event.price}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

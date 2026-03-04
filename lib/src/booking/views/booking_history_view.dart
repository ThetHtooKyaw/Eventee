import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/app_error.dart';
import 'package:eventee/src/booking/models/event_history.dart';
import 'package:eventee/src/booking/view_models/booking_history_view_model.dart';
import 'package:eventee/src/booking/widgets/custom_icon_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/core/widgets/loading_column.dart';

class BookingHistoryView extends StatefulWidget {
  const BookingHistoryView({super.key});

  @override
  State<BookingHistoryView> createState() => _BookingHistoryViewState();
}

class _BookingHistoryViewState extends State<BookingHistoryView> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingHistoryViewModel>().fetchBookingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Bookings', style: t.textTheme.titleSmall),
          bottom: TabBar(
            labelColor: AppColor.primary,
            unselectedLabelColor: AppColor.textPlaceholder,
            indicatorColor: AppColor.primary,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),

        body: Consumer<BookingHistoryViewModel>(
          builder: (context, vm, child) {
            if (vm.isScreenLoading) {
              return const LoadingColumn(message: 'Loading booking history');
            }

            if (vm.errorMessage != null) {
              return AppError(errorMessage: vm.errorMessage!);
            }

            return TabBarView(
              children: [
                _buildBookingList(
                  vm,
                  vm.activeEventList,
                  'No active bookings found!',
                ),
                _buildBookingList(
                  vm,
                  vm.completedEventList,
                  'No completed bookings found!',
                ),
                _buildBookingList(
                  vm,
                  vm.cancelledEventList,
                  'No cancelled bookings found!',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BookingHistoryViewModel vm,
    List<EventHistoryModel> bookings,
    String emptyMessage,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: Theme.of(context).textTheme.bodyLarge),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppFormat.primaryPadding,
        vertical: AppFormat.secondaryPadding,
      ),
      shrinkWrap: true,
      itemCount: bookings.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        EventHistoryModel event = bookings[index];

        final eventDate = vm.formatDate(event.date);
        final eventStartTime = vm.formatTime(event.startTime);
        final eventEndTime = vm.formatTime(event.endTime);

        return _buildBookingCard(
          event,
          eventDate,
          eventStartTime,
          eventEndTime,
        );
      },
    );
  }

  Widget _buildBookingCard(
    EventHistoryModel event,
    String eventDate,
    String eventStartTime,
    String eventEndTime,
  ) {
    final t = Theme.of(context);

    return CouponCard(
      height: 200,
      curveAxis: Axis.vertical,
      backgroundColor: AppColor.primary,
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
              style: t.textTheme.titleSmall?.copyWith(color: AppColor.white),
            ),
            const SizedBox(height: 10),

            // Location
            CustomIconLabel(
              icon: Icons.location_on_outlined,
              child: Text(
                event.location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: AppColor.white,
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
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: AppColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Date
                  Text(
                    eventDate,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: AppColor.textPlaceholder,
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
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: AppColor.white,
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
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.quantity.toString(),
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: AppColor.primary,
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
                        : AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.status.toUpperCase(),
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: AppColor.primary,
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
                    CircularProgressIndicator(),
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
                color: AppColor.white,
                borderRadius: BorderRadius.circular(
                  AppFormat.secondaryBorderRadius,
                ),
              ),
              child: Text(
                '฿${event.price}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: t.textTheme.bodyLarge?.copyWith(
                  color: AppColor.primary,
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

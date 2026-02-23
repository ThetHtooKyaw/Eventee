import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/app_error.dart';
import 'package:eventee/src/booking/models/event_history.dart';
import 'package:eventee/src/booking/view_models/booking_history_view_model.dart';
import 'package:eventee/src/booking/view_models/event_details_view_model.dart';
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

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Booking History')),

      body: Consumer<BookingHistoryViewModel>(
        builder: (context, vm, child) {
          if (vm.isScreenLoading) {
            return const LoadingColumn(message: 'Loading booking history');
          }

          if (vm.errorMessage != null) {
            return AppError(errorMessage: vm.errorMessage!);
          }

          if (vm.eventHistory.isEmpty) {
            return Center(
              child: Text(
                'No booking history found!',
                style: t.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
              vertical: AppFormat.secondaryPadding,
            ),
            shrinkWrap: true,
            itemCount: vm.eventHistory.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemBuilder: (context, index) {
              EventHistoryModel event = vm.eventHistory[index];

              String eventDate = context
                  .read<EventDetailsViewModel>()
                  .formatDate(event.eventDate);

              return _buildBookingHistoryCard(t, event, eventDate);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingHistoryCard(
    ThemeData t,
    EventHistoryModel event,
    String eventDate,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppFormat.primaryBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Card Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #', // ${event.id!.substring(0, 8)}
                  style: t.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),

                Text(
                  eventDate,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Booking Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppFormat.secondaryBorderRadius,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: event.eventImage,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) =>
                        CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 20),

                // Booking Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleSmall?.copyWith(
                          color: AppColor.primary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        "Total Amount: ${event.totalAmount} Baht",
                        style: t.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),

                      Text(
                        'Qty: ${event.quantity}',
                        style: t.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(),
            const SizedBox(height: 12),

            // Event Location
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.textPrimary),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      event.eventLocation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

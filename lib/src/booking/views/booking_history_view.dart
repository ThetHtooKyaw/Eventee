import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/src/admin/model/event_history.dart';
import 'package:eventee/src/booking/view_models/booking_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String formatDate(DateTime eventDate) {
    return DateFormat('dd, MMM, yyyy').format(eventDate);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.watch<BookingHistoryViewModel>();

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Booking History')),

      body: StreamBuilder<List<EventHistoryModel>>(
        stream: vm.historyStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingColumn(message: 'Loading Booking History');
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No booking history found!'));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: t.textTheme.bodyLarge?.copyWith(color: Colors.red),
              ),
            );
          }

          List<EventHistoryModel> events = snapshot.data;

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppFormat.primaryPadding),
            shrinkWrap: true,
            itemCount: events.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemBuilder: (context, index) {
              EventHistoryModel event = events[index];

              String eventDate = formatDate(event.eventDate);

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
      margin: const EdgeInsets.only(bottom: 20),
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

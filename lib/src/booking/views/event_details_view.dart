import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/admin/model/event.dart';
import 'package:eventee/src/booking/view_models/event_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:eventee/core/widgets/quantity_selector.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventDetailsView extends StatefulWidget {
  final EventModel event;
  const EventDetailsView({super.key, required this.event});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  int quantity = 1;

  String formatDate(DateTime eventDate) {
    return DateFormat('dd, MMM, yyyy').format(eventDate);
  }

  int formatPrice(String ticketPrice) {
    return int.parse(ticketPrice);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Consumer<EventDetailsViewModel>(
      builder: (context, vm, child) {
        if (vm.bookingError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(vm.bookingError!.message),
                backgroundColor: Colors.red,
              ),
            );
            vm.clearBookingError();
          });
        }

        if (vm.loading) {
          return LoadingColumn(message: 'Making payment');
        }
        return Scaffold(
          // Bottom Bar
          bottomNavigationBar: _buildBookNow(context, t, vm),

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Header
              _buildBookingHeader(context, t),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppFormat.primaryPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Details
                    Text(
                      'About Event',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.event.eventDetail,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Number of Tickets',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        QuantitySelector(
                          quantity: quantity,
                          onIncrement: () => setState(() => quantity += 1),
                          onDecrement: () => setState(() => quantity -= 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stack _buildBookingHeader(BuildContext context, ThemeData t) {
    return Stack(
      children: [
        // Booking Image
        CachedNetworkImage(
          imageUrl: widget.event.eventImage,
          height: 400,
          width: double.infinity,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, progress) =>
              CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),

        // Action Button
        SafeArea(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.only(
                left: AppFormat.primaryPadding,
                top: AppFormat.secondaryPadding,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(
                  AppFormat.secondaryBorderRadius,
                ),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ),

        // Event Info
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
              vertical: AppFormat.secondaryPadding,
            ),
            decoration: BoxDecoration(color: Colors.black45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name
                Text(
                  widget.event.eventName,
                  style: t.textTheme.titleLarge?.copyWith(
                    color: AppColor.white,
                  ),
                ),
                const SizedBox(height: 4),

                // Event Date & Location
                Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20, color: AppColor.white),
                    const SizedBox(width: 10),
                    Text(
                      formatDate(widget.event.eventDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: AppColor.white,
                      ),
                    ),
                    const SizedBox(width: 40),

                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppColor.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.event.eventLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: AppColor.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookNow(
    BuildContext context,
    ThemeData t,
    EventDetailsViewModel vm,
  ) {
    final displayAmount = widget.event.ticketPrice * quantity;

    return Padding(
      padding: const EdgeInsets.all(AppFormat.primaryPadding),
      child: Row(
        children: [
          Text(
            'Amount: $displayAmount Baht',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.titleSmall,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await vm.makePayment(
                  event: widget.event,
                  amount: displayAmount.toDouble(),
                  quantity: quantity,
                );

                if (vm.bookingError == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event ticket purchased successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Book Now"),
            ),
          ),
        ],
      ),
    );
  }
}

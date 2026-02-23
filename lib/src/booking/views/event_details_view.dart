import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/admin/model/event.dart';
import 'package:eventee/src/booking/models/booking.dart';
import 'package:eventee/src/booking/view_models/event_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:eventee/core/widgets/quantity_selector.dart';
import 'package:provider/provider.dart';

class EventDetailsView extends StatefulWidget {
  final EventModel event;
  const EventDetailsView({super.key, required this.event});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  int quantity = 1;

  Future<void> bookEvent(BuildContext context, double totalAmount) async {
    final vm = context.read<EventDetailsViewModel>();

    await vm.makePayment(
      bookedEvent: BookingModel.fromEvent(
        event: widget.event,
        totalAmount: totalAmount,
        quantity: quantity,
      ),
    );

    if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!), backgroundColor: Colors.red),
      );
      vm.setError(null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event ticket purchased successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isActionLoading = context.select<EventDetailsViewModel, bool>(
      (vm) => vm.isActionLoading,
    );

    return Stack(
      children: [
        Scaffold(
          // Bottom Bar
          bottomNavigationBar: _buildBookNow(context, t, isActionLoading),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Header
                _buildBookingHeader(context, t),
                const SizedBox(height: 20),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppFormat.primaryPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Details
                      Text('About Event', style: t.textTheme.titleLarge),
                      const SizedBox(height: 20),

                      Text(
                        widget.event.eventDetail,
                        style: t.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Number of Tickets',
                            style: t.textTheme.titleLarge,
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
          ),
        ),

        if (isActionLoading)
          LoadingOverlayColumn(message: 'Processing payment'),
      ],
    );
  }

  Widget _buildBookingHeader(BuildContext context, ThemeData t) {
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
                    const Icon(
                      Icons.calendar_month,
                      size: 20,
                      color: AppColor.white,
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        context.read<EventDetailsViewModel>().formatDate(
                          widget.event.eventDate,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.bodyLarge?.copyWith(
                          color: AppColor.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),

                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppColor.white,
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        widget.event.eventLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.bodyLarge?.copyWith(
                          color: AppColor.white,
                        ),
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
    bool isActionLoading,
  ) {
    final totalAmount = widget.event.ticketPrice * quantity;

    return Padding(
      padding: const EdgeInsets.all(AppFormat.primaryPadding),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Amount', style: t.textTheme.bodyMedium),
              Text(
                '${totalAmount.toStringAsFixed(2)} Baht',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(width: 20),

          Expanded(
            child: ElevatedButton(
              onPressed: isActionLoading
                  ? null
                  : () => bookEvent(context, totalAmount),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:eventee/src/create_event/model/event.dart';
import 'package:eventee/src/booking/models/booking.dart';
import 'package:eventee/src/booking/view_models/event_details_view_model.dart';
import 'package:eventee/src/booking/widgets/bottom_curve_clipper.dart';
import 'package:eventee/src/booking/widgets/info_card.dart';
import 'package:eventee/src/booking/widgets/timeline_card.dart';
import 'package:eventee/src/home/viewa_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:eventee/core/widgets/quantity_selector.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class EventDetailsView extends StatefulWidget {
  final EventModel event;
  const EventDetailsView({super.key, required this.event});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  int quantity = 1;
  bool isDesExpanded = false;

  Future<void> bookEvent(BuildContext context, double total) async {
    final vm = context.read<EventDetailsViewModel>();

    await vm.makePayment(
      bookedEvent: BookingModel.fromEvent(
        event: widget.event,
        total: total,
        quantity: quantity,
        status: 'active',
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
    final homeVM = context.read<HomeViewModel>();
    final eventDate = homeVM.formatDateMonthDay(widget.event.date);
    final eventStartTime = homeVM.formatTime(widget.event.startTime);
    final eventEndTime = homeVM.formatTime(widget.event.endTime);

    return Stack(
      children: [
        Scaffold(
          // TODO: Get User Image
          appBar: ViewAppbar(actionIcon: CircleAvatar()),

          // Bottom Bar
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
              vertical: AppFormat.secondaryPadding,
            ),
            child: ElevatedButton(
              onPressed: () => _showTicketSheet(
                t,
                eventDate,
                eventStartTime,
                eventEndTime,
                isActionLoading,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Get a Ticket"),
            ),
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppFormat.secondaryPadding),
                // Image
                _buildImageContainer(t, eventDate),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppFormat.primaryPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'By',
                            style: t.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColor.primary,
                            child: Text(
                              'W',
                              style: t.textTheme.bodyLarge?.copyWith(
                                color: AppColor.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // TODO: Get Organizer Name
                          // Organizer Name
                          Expanded(
                            child: Text(
                              'Organizer Name',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: AppFormat.secondaryBorderRadius,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(
                                AppFormat.primaryBorderRadius,
                              ),
                            ),
                            child: Text(
                              '฿${widget.event.price}',
                              style: t.textTheme.titleSmall?.copyWith(
                                color: AppColor.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // TODO: Implement Read More Feature
                      // Description
                      Text(
                        'About',
                        style: t.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ReadMoreText(
                        widget.event.description,
                        trimLines: 3,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Read More',
                        trimExpandedText: 'Read Less',
                        style: t.textTheme.bodyLarge?.copyWith(
                          color: AppColor.textPlaceholder,
                        ),
                        moreStyle: t.textTheme.bodyLarge?.copyWith(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        lessStyle: t.textTheme.bodyLarge?.copyWith(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Timeline
                      Text(
                        'Timeline Event',
                        style: t.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TimelineCard(
                        label: 'Opening Time',
                        eventDate: eventDate,
                        eventTime: eventStartTime,
                      ),
                      const SizedBox(height: 10),

                      TimelineCard(
                        label: 'Closing Time',
                        eventDate: eventDate,
                        eventTime: eventEndTime,
                      ),
                      const SizedBox(height: 20),

                      // Ticket Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Number of Tickets',
                            style: t.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildImageContainer(ThemeData t, String eventDate) {
    return SizedBox(
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Image
          ClipPath(
            clipper: BottomCurveClipper(),
            child: CachedNetworkImage(
              imageUrl: widget.event.imageUrl,
              height: 300,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, progress) =>
                  SkeletonWidget(height: 300, width: double.infinity),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        widget.event.location,
                        style: t.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // TODO: Implement Save Feature
                // Save Button
                GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColor.white,
                    child: Icon(Icons.bookmark_outline_outlined, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Date
          Positioned(
            bottom: 0,
            left: 135,
            right: 135,
            child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  eventDate,
                  style: t.textTheme.bodyLarge?.copyWith(
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _showTicketSheet(
    ThemeData t,
    String eventDate,
    String eventStartTime,
    String eventEndTime,
    bool isActionLoading,
  ) {
    final total = widget.event.price * quantity;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppFormat.secondaryPadding,
            horizontal: AppFormat.primaryPadding,
          ),
          height: MediaQuery.of(context).size.height * 0.7,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),

          child: Column(
            children: [
              const Divider(
                color: AppColor.primary,
                thickness: 6,
                indent: 130,
                endIndent: 130,
                radius: BorderRadius.all(
                  Radius.circular(AppFormat.secondaryBorderRadius),
                ),
              ),
              const SizedBox(height: 20),

              // Coupon Card
              CouponCard(
                height: 460,
                curveAxis: Axis.horizontal,
                backgroundColor: AppColor.primary,
                borderRadius: AppFormat.primaryPadding,
                curveRadius: AppFormat.primaryPadding,
                curvePosition: 240,
                firstChild: Padding(
                  padding: const EdgeInsets.all(AppFormat.primaryPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ticket Title
                      Center(
                        child: Text(
                          '${widget.event.title} Ticket',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.titleLarge?.copyWith(
                            color: AppColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Ticket Holder Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
                                  style: t.textTheme.bodyMedium?.copyWith(
                                    color: AppColor.placeholder,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // TODO: Get User Name
                                Text(
                                  'Tony',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.textTheme.titleSmall?.copyWith(
                                    color: AppColor.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity',
                                  style: t.textTheme.bodyMedium?.copyWith(
                                    color: AppColor.placeholder,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  quantity.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.textTheme.titleSmall?.copyWith(
                                    color: AppColor.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Event Location
                      Text(
                        'Location',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: AppColor.placeholder,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        widget.event.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleSmall?.copyWith(
                          color: AppColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.all(AppFormat.primaryPadding),
                  child: Column(
                    children: [
                      Text(
                        'Ticket will be active from',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: AppColor.placeholder,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Timeline
                      InfoCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  eventStartTime,
                                  style: t.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  eventDate,
                                  style: t.textTheme.bodyMedium?.copyWith(
                                    color: AppColor.textPlaceholder,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  eventEndTime,
                                  style: t.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  eventDate,
                                  style: t.textTheme.bodyMedium?.copyWith(
                                    color: AppColor.textPlaceholder,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Price
                      InfoCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: t.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '฿${total.toStringAsFixed(2)}',
                              style: t.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Make Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isActionLoading
                      ? null
                      : () => bookEvent(context, total),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Make Payment"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

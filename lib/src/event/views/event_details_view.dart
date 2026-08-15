import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/event/model/event.dart';
import 'package:eventee/src/event/model/booking.dart';
import 'package:eventee/src/event/view_models/event_details_view_model.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';
import 'package:eventee/src/event/widgets/bottom_curve_clipper.dart';
import 'package:eventee/src/event/widgets/info_card.dart';
import 'package:eventee/src/event/widgets/timeline_card.dart';
import 'package:eventee/src/favourite/view_models/favourite_view_model.dart';
import 'package:flutter/material.dart';
import 'package:eventee/core/widgets/quantity_selector.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class EventDetailsView extends StatefulWidget {
  final EventModel event;
  const EventDetailsView({super.key, required this.event});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  late final EventDetailsViewModel _viewModel;
  int quantity = 1;
  bool isDesExpanded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<EventDetailsViewModel>();
    _viewModel.addListener(_onViewModelChanged);
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
    } else if (_viewModel.successMessage != null && mounted) {
      AppSnackbars.showSuccessSnackbar(context, _viewModel.successMessage!);
      _viewModel.setSuccess(null);
    }
  }

  Future<void> _bookEvent(EventDetailsViewModel vm, double total) async {
    await vm.makePayment(
      bookedEvent: BookingModel.fromEvent(
        event: widget.event,
        total: total,
        quantity: quantity,
        status: 'active',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<EventListViewModel>();
    final eventDate = vm.formatDateMonthDay(widget.event.date);
    final eventStartTime = vm.formatTime(widget.event.startTime);
    final eventEndTime = vm.formatTime(widget.event.endTime);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        // Bottom Section
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppFormat.primaryPadding,
            vertical: AppFormat.secondaryPadding,
          ),
          child: ElevatedButton(
            onPressed: () {
              final vm = context.read<EventDetailsViewModel>();
              _showTicketSheet(
                theme,
                eventDate,
                eventStartTime,
                eventEndTime,
                vm,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("Get a Ticket"),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppFormat.secondaryPadding),
                // Image
                _buildImageContainer(theme, eventDate),

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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'By',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              'W',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
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
                              style: theme.textTheme.bodyLarge?.copyWith(
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
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(
                                AppFormat.primaryBorderRadius,
                              ),
                            ),
                            child: Text(
                              '฿${widget.event.price}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Ticket Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Number of Tickets',
                            style: theme.textTheme.titleSmall?.copyWith(
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
                      const SizedBox(height: 10),

                      // Timeline
                      Text(
                        'Timeline Event',
                        style: theme.textTheme.titleSmall?.copyWith(
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

                      // Description
                      Text(
                        'About',
                        style: theme.textTheme.titleSmall?.copyWith(
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
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColor.textPlaceholder,
                        ),
                        moreStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        lessStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
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
      ),
    );
  }

  Widget _buildImageContainer(ThemeData theme, String eventDate) {
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
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 25,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Location
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     vertical: 6,
                //     horizontal: 16,
                //   ),
                //   decoration: BoxDecoration(
                //     color: AppColor.white,
                //     borderRadius: BorderRadius.circular(30),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(Icons.flag, size: 20),
                //       const SizedBox(width: 10),
                //       Text(
                //         widget.event.location,
                //         style: theme.textTheme.bodyLarge?.copyWith(
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // Save Button
                Selector<FavouriteViewModel, bool>(
                  selector: (_, vm) =>
                      vm.favouritedEventIds.contains(widget.event.eventId),
                  builder: (context, isFavourited, child) {
                    return CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () => context
                            .read<FavouriteViewModel>()
                            .toggleFavourite(widget.event),
                        icon: Icon(
                          isFavourited ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    );
                  },
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
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  eventDate,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
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
    ThemeData theme,
    String eventDate,
    String eventStartTime,
    String eventEndTime,
    EventDetailsViewModel vm,
  ) {
    final total = widget.event.price * quantity;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: vm,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppFormat.secondaryPadding,
            horizontal: AppFormat.primaryPadding,
          ),
          height: MediaQuery.of(sheetContext).size.height * 0.7,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Divider(
                color: theme.colorScheme.primary,
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
                backgroundColor: theme.colorScheme.primary,
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
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
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
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Selector<AccountViewModel, String>(
                                  selector: (_, vm) =>
                                      vm.user?.username ?? 'Unknown',
                                  builder: (_, username, child) {
                                    return Text(
                                      username,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Ticket Quantity
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  quantity.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        widget.event.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
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
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  eventDate,
                                  style: theme.textTheme.bodyMedium?.copyWith(
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
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  eventDate,
                                  style: theme.textTheme.bodyMedium?.copyWith(
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
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '฿${total.toStringAsFixed(2)}',
                              style: theme.textTheme.titleSmall?.copyWith(
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
              Selector<EventDetailsViewModel, bool>(
                selector: (_, vm) => vm.isActionLoading,
                builder: (_, isLoading, _) {
                  return ElevatedButton(
                    onPressed: () => isLoading ? null : _bookEvent(vm, total),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Make Payment"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

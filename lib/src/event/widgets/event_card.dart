import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/src/event/model/event.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final double cardWidth;
  const EventCard({super.key, required this.event, this.cardWidth = 340});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.read<EventListViewModel>();
    final eventDate = vm.formatDateMonthDay(event.date);
    final eventTime = vm.formatTime(event.startTime);

    return Container(
      padding: const EdgeInsets.all(AppFormat.secondaryPadding),
      width: cardWidth,
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.placeholder, width: 0.5),
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Event Image
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: event.imageUrl,
                progressIndicatorBuilder: (context, url, progress) =>
                    SkeletonWidget(height: 180, width: 300),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  width: cardWidth - 20,
                  decoration: BoxDecoration(
                    color: AppColor.placeholder,
                    borderRadius: BorderRadiusGeometry.circular(
                      AppFormat.primaryBorderRadius - 6,
                    ),
                  ),
                  child: Icon(Icons.error),
                ),
                imageBuilder: (context, imageProvider) => Container(
                  height: 180,
                  width: cardWidth - 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusGeometry.circular(
                      AppFormat.primaryBorderRadius - 6,
                    ),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Event Category
              Container(
                margin: const EdgeInsets.only(left: 10, top: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppFormat.secondaryPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(
                    AppFormat.secondaryBorderRadius - 6,
                  ),
                ),
                child: Text(
                  event.category,
                  textAlign: TextAlign.center,
                  style: t.textTheme.bodyLarge?.copyWith(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Event Title
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Event Location, Date & Time
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: AppColor.textPlaceholder,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              Icon(Icons.timer, size: 20),
              const SizedBox(width: 6),
              Text(
                '$eventDate - $eventTime',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: AppColor.textPlaceholder,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Event Price
          Row(
            children: [
              Text(
                '฿${event.price}',
                style: t.textTheme.titleSmall?.copyWith(
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/Person',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: AppColor.textPlaceholder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

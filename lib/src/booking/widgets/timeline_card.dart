import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class TimelineCard extends StatelessWidget {
  final String label;
  final String eventDate;
  final String eventTime;
  const TimelineCard({
    super.key,
    required this.label,
    required this.eventDate,
    required this.eventTime,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppFormat.primaryPadding),
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.placeholder.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Icon(Icons.timer_outlined, size: 16, color: AppColor.textPlaceholder),
          const SizedBox(width: 6),
          Text(
            '$eventDate, $eventTime',
            style: t.textTheme.bodyMedium?.copyWith(
              color: AppColor.textPlaceholder,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

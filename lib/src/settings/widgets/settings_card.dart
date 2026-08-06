import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool switchValue;
  final ValueChanged onChanged;
  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.switchValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: AppFormat.primaryPadding,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 24),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Switch(
            value: switchValue,
            onChanged: onChanged,
            activeTrackColor: theme.colorScheme.onPrimary.withOpacity(0.5),
            activeColor: theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}

class SettingsLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const SettingsLinkCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColor.placeholder.withOpacity(0.4),
        highlightColor: AppColor.placeholder.withOpacity(0.4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: AppFormat.primaryPadding,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 24),
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Icon(Icons.chevron_right, color: theme.colorScheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

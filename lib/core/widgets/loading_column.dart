import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

class LoadingColumn extends StatelessWidget {
  final String message;
  const LoadingColumn({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('$message...', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class LoadingOverlayColumn extends StatelessWidget {
  final String message;
  const LoadingOverlayColumn({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppFormat.primaryPadding,
            vertical: 40,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                '$message...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

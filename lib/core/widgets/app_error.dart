import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  final String errorMessage;
  const AppError({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: errorMessage.isNotEmpty,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          errorMessage,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.red),
        ),
      ),
    );
  }
}

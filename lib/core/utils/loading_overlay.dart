import 'package:eventee/core/themes/app_format.dart';
import 'package:flutter/material.dart';

Future<void> showLoadingDialog({
  required BuildContext context,
  required String message,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppFormat.primaryPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                AppFormat.secondaryBorderRadius,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$message...'),
                const SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void hideLoadingDialog({required BuildContext context}) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

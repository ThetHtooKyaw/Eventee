import 'package:flutter/material.dart';

Future<void> showLoadingDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: LoadingColumn(message: message),
    ),
  );
}

void hideLoadingDialog(BuildContext context) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class LoadingColumn extends StatelessWidget {
  final String message;
  const LoadingColumn({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('$message...'),
        ],
      ),
    );
  }
}

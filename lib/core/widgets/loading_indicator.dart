import 'package:eventee/core/themes/app_color.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Center(child: CircularProgressIndicator(color: AppColor.primary)),
    );
  }
}

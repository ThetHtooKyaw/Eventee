import 'package:eventee/core/themes/app_color.dart';
import 'package:flutter/material.dart';

class AppTextStyle {
  AppTextStyle._();

  static const displayLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.25,
    color: AppColor.textPrimary,
  );

  static const titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColor.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColor.textPrimary,
  );

  static const titleSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColor.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColor.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColor.textPrimary,
  );

  static const bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColor.textSecondary,
  );

  static const bodySmall = TextStyle(fontSize: 12, color: AppColor.textPrimary);
}

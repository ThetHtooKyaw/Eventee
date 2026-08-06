import 'package:flutter/material.dart';

class AppTextStyle {
  AppTextStyle._();

  static const displayLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.25,
  );

  static const titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const titleMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const titleSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const bodySmall = TextStyle(fontSize: 12);
}

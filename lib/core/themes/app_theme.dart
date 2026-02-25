import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/themes/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:eventee/core/themes/app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColor.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColor.primary,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColor.primary,
            secondary: AppColor.secondary,
            surface: AppColor.white,
            onPrimary: AppColor.white,
            error: AppColor.error,
          ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyle.displayLarge,
        titleLarge: AppTextStyle.titleLarge,
        titleMedium: AppTextStyle.titleMedium,
        titleSmall: AppTextStyle.titleSmall,
        bodyLarge: AppTextStyle.bodyLarge,
        bodyMedium: AppTextStyle.bodyMedium,
        bodySmall: AppTextStyle.bodySmall,
      ),

      iconTheme: IconThemeData(color: AppColor.primary, size: 30),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.textPrimary,
        elevation: 0,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.secondary,
        backgroundColor: AppColor.white,
        elevation: 8,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.black),

      cardTheme: CardThemeData(
        color: AppColor.white,
        shadowColor: AppColor.textPrimary.withAlpha(50),
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(10),
          foregroundColor: AppColor.white,
          backgroundColor: AppColor.primary,
          disabledBackgroundColor: AppColor.textPlaceholder,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
          ),
          textStyle: AppTextStyle.titleSmall,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(160, 60),
          foregroundColor: AppColor.white,
          disabledBackgroundColor: AppColor.textPlaceholder,
          side: const BorderSide(color: AppColor.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
          ),
          textStyle: AppTextStyle.bodyLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.white,
          disabledForegroundColor: AppColor.textPlaceholder,
          textStyle: AppTextStyle.bodyLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColor.white,
          disabledBackgroundColor: AppColor.textPlaceholder,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppFormat.secondaryBorderRadius,
            ),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
          borderSide: BorderSide.none,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: AppTextStyle.bodyLarge.copyWith(
          color: AppColor.textPlaceholder,
        ),
        hintStyle: AppTextStyle.bodyLarge.copyWith(
          color: AppColor.textPlaceholder,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

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
      scaffoldBackgroundColor: AppColor.lightBackground,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.light(
        primary: AppColor.lightPrimary,
        surface: AppColor.lightBackground,
        onPrimary: AppColor.lightTextSecondary,
        secondary: AppColor.textPlaceholder,
        onSecondary: AppColor.darkTextPlaceholder,
        error: AppColor.error,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyle.displayLarge.copyWith(
          color: AppColor.lightTextPrimary,
        ),
        titleLarge: AppTextStyle.titleLarge.copyWith(
          color: AppColor.lightTextPrimary,
        ),
        titleMedium: AppTextStyle.titleMedium.copyWith(
          color: AppColor.lightTextPrimary,
        ),
        titleSmall: AppTextStyle.titleSmall.copyWith(
          color: AppColor.lightTextPrimary,
        ),
        bodyLarge: AppTextStyle.bodyLarge.copyWith(
          color: AppColor.lightTextPrimary,
        ),
        bodyMedium: AppTextStyle.bodyMedium.copyWith(
          color: AppColor.lightTextPrimary,
        ),
        bodySmall: AppTextStyle.bodySmall.copyWith(
          color: AppColor.lightTextPrimary,
        ),
      ),

      iconTheme: IconThemeData(color: AppColor.lightPrimary, size: 30),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.lightBackground,
        foregroundColor: AppColor.lightTextPrimary,
        elevation: 0,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColor.lightBackground,
        selectedItemColor: AppColor.lightPrimary,
        elevation: 8,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColor.lightPrimary,
      ),

      cardTheme: CardThemeData(
        color: AppColor.lightBackground,
        shadowColor: AppColor.lightTextPrimary,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(160, 60),
          foregroundColor: AppColor.lightTextSecondary,
          backgroundColor: AppColor.lightPrimary,
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
          foregroundColor: AppColor.lightPrimary,
          disabledBackgroundColor: AppColor.textPlaceholder,
          side: const BorderSide(color: AppColor.lightPrimary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
          ),
          textStyle: AppTextStyle.bodyLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.lightTextSecondary,
          disabledForegroundColor: AppColor.textPlaceholder,
          textStyle: AppTextStyle.bodyLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColor.lightPrimary,
          disabledForegroundColor: AppColor.textPlaceholder,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppFormat.secondaryBorderRadius,
            ),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
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

  static ThemeData get darkTheme {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColor.darkBackground,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.dark(
        primary: AppColor.darkPrimary,
        surface: AppColor.darkBackground,
        onPrimary: AppColor.darkTextSecondary,
        secondary: AppColor.darkTextPlaceholder,
        onSecondary: AppColor.textPlaceholder,
        error: AppColor.error,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyle.displayLarge.copyWith(
          color: AppColor.darkTextPrimary,
        ),
        titleLarge: AppTextStyle.titleLarge.copyWith(
          color: AppColor.darkTextPrimary,
        ),
        titleMedium: AppTextStyle.titleMedium.copyWith(
          color: AppColor.darkTextPrimary,
        ),
        titleSmall: AppTextStyle.titleSmall.copyWith(
          color: AppColor.darkTextPrimary,
        ),
        bodyLarge: AppTextStyle.bodyLarge.copyWith(
          color: AppColor.darkTextPrimary,
        ),
        bodyMedium: AppTextStyle.bodyMedium.copyWith(
          color: AppColor.darkTextPrimary,
        ),
        bodySmall: AppTextStyle.bodySmall.copyWith(
          color: AppColor.darkTextPrimary,
        ),
      ),

      iconTheme: IconThemeData(color: AppColor.darkPrimary, size: 30),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.darkBackground,
        foregroundColor: AppColor.darkTextPrimary,
        elevation: 0,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColor.darkBackground,
        selectedItemColor: AppColor.darkPrimary,
        elevation: 8,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColor.darkPrimary,
      ),

      cardTheme: CardThemeData(
        shadowColor: AppColor.darkPrimary,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(160, 60),
          foregroundColor: AppColor.darkTextSecondary,
          backgroundColor: AppColor.darkPrimary,
          disabledBackgroundColor: AppColor.darkTextPlaceholder,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
          ),
          textStyle: AppTextStyle.titleSmall,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(160, 60),
          foregroundColor: AppColor.darkPrimary,
          disabledBackgroundColor: AppColor.darkTextPlaceholder,
          side: const BorderSide(color: AppColor.darkPrimary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
          ),
          textStyle: AppTextStyle.bodyLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.darkTextSecondary,
          disabledForegroundColor: AppColor.darkTextPlaceholder,
          textStyle: AppTextStyle.bodyLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColor.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppFormat.secondaryBorderRadius,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
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

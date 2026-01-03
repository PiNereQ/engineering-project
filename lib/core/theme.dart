import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFF1D1); // main background
  static const surface = Color(0xFFFFFFFF); // tiles, light background
  static const popupOverlay = Colors.black54; // overlay behind popups ("Filtruj", "Sortuj", etc)

  static const primaryButton = Color(0xFFFFB5A7); // buttons
  static const primaryButtonPressed = Color(0xFFB2B2B2); // pressed button
  static const primaryButtonDark = Color(0xFF5C0F00); // icons on buttons
  static const secondaryButton = Color(0xFFEBEBEB); // secondary buttons ("Pomin" etc)

  static const textPrimary = Color(0xFF000000); // main text / borders
  static const textSecondary = Color(0xFF656565); // less important text

  static const alertButton = Color(0xFFFFD1D1); // alert button
  static const alertText = Color(0xFFB21414); // text + icons on alert

  static const notificationDot = Color(0xFFFF405F); // notification badge
  static const checkIcon = Color(0xFFD88170); // checkbox/radio icons
}

  ThemeData appTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,

    // material colors
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryButton,
      secondary: AppColors.primaryButton,
      surface: AppColors.surface,
      onPrimary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),

    // text
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primaryButton,
      selectionColor: AppColors.primaryButton,
      selectionHandleColor: AppColors.primaryButton,
    ),

    // progressy
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryButton,
    ),

    // snackbars
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: TextStyle(
        fontFamily: 'Itim',
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
    ),

    // (focus, ripple, etc)
    focusColor: AppColors.primaryButton,
    highlightColor: AppColors.primaryButton.withValues(alpha: 0.12),
    splashColor: AppColors.primaryButton.withValues(alpha: 0.12),
  );
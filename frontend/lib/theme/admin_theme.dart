import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class AdminColors {
  const AdminColors._();

  static const Color surface = AppColors.surface;
  static const Color surfaceSubtle = AppColors.background;
  static const Color border = AppColors.subtleBorder;
  static const Color iconMuted = AppColors.textMuted;
  static const Color mutedText = AppColors.textSecondary;
  static const Color error = AppColors.error;
  static const Color selected = AppColors.accent;
  static const Color selectedText = AppColors.textInverse;

  static const Color success = AppColors.success;
  static const Color successBackground = Color(0xFFEAF7EF);
  static const Color dangerBackground = Color(0xFFFDECEC);
  static const Color disabledFill = Color(0xFFE2E8F0);
  static const Color disabledText = AppColors.textMuted;
}

class AdminTextStyles {
  const AdminTextStyles._();

  static const TextStyle eyebrow = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle tileTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle tileSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
  );

  static const TextStyle helper = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
  );

  static const TextStyle empty = TextStyle(
    color: AppColors.textMuted,
    fontSize: 14,
  );

  static const TextStyle error = TextStyle(
    color: AppColors.error,
    fontSize: 13,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );
}

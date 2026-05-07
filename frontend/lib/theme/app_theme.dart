import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF1E293B);
  static const Color secondary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color accent = primary;

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Colors.white;

  static const Color border = Color(0xFF475569);
  static const Color subtleBorder = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF97316);
  static const Color success = Color(0xFF16A34A);

  static const Color overlay = Colors.black26;
  static const Color shadow = Colors.black12;
  static const Color transparent = Colors.transparent;
}

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
  );

  static const TextStyle label = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle error = TextStyle(color: AppColors.error);

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle link = TextStyle(
    color: AppColors.secondary,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static const TextStyle screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle screenSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  static const TextStyle inverseTitle = TextStyle(
    color: AppColors.textInverse,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
}

class AppTheme {
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color background = AppColors.background;
  static const Color accent = AppColors.accent;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color border = AppColors.border;
  static const Color error = AppColors.error;

  static ThemeData get theme => ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: background,
      error: error,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return primary.withAlpha(128);
          }
          return primary;
        }),
        foregroundColor: WidgetStateProperty.all(AppColors.textInverse),
        overlayColor: WidgetStateProperty.all(AppColors.transparent),
        surfaceTintColor: WidgetStateProperty.all(AppColors.transparent),
        shadowColor: WidgetStateProperty.all(AppColors.transparent),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textStyle: WidgetStateProperty.all(AppTextStyles.button),
        elevation: WidgetStateProperty.all(0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      hintStyle: AppTextStyles.bodySecondary,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: secondary, width: 1.5),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: error, width: 1.5),
      ),
    ),
  );

  static ButtonStyle get btnDark => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) return primary.withAlpha(128);
      return primary;
    }),
    foregroundColor: WidgetStateProperty.all(AppColors.textInverse),
    overlayColor: WidgetStateProperty.all(AppColors.transparent),
    surfaceTintColor: WidgetStateProperty.all(AppColors.transparent),
    shadowColor: WidgetStateProperty.all(AppColors.transparent),
    minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textStyle: WidgetStateProperty.all(AppTextStyles.button),
    elevation: WidgetStateProperty.all(0),
  );

  static ButtonStyle get btnLight => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) {
        return secondary.withAlpha(128);
      }
      return secondary;
    }),
    foregroundColor: WidgetStateProperty.all(AppColors.textInverse),
    overlayColor: WidgetStateProperty.all(AppColors.transparent),
    surfaceTintColor: WidgetStateProperty.all(AppColors.transparent),
    shadowColor: WidgetStateProperty.all(AppColors.transparent),
    minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textStyle: WidgetStateProperty.all(AppTextStyles.button),
    elevation: WidgetStateProperty.all(0),
  );
}

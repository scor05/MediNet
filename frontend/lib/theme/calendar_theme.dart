import 'package:flutter/material.dart';

class CalendarColors {
  const CalendarColors._();

  // Header
  static Color todayHeader(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color normalHeader(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color todayHeaderText(BuildContext context) => Colors.white;

  static Color normalDayName(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color normalDayNumber(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  // Grid
  static Color divider(BuildContext context) => Theme.of(context).dividerColor;

  static Color hourText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color calendarBackground(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  // Appointment status colors
  static final Color appointmentAccepted = Colors.green.shade100;
  static final Color appointmentRequested = Colors.orange.shade100;
  static final Color appointmentCancelled = Colors.red.shade100;
  static final Color appointmentUnknown = Colors.grey.shade100;

  // FAB colors
  static final Color createAppointmentFab = Colors.green.shade700;
  static final Color createScheduleFab = Colors.orange.shade700;

  // Overlay
  static const Color fabOverlay = Colors.black26;

  // Shadows
  static const Color lightShadow = Colors.black12;
}

class CalendarTextStyles {
  const CalendarTextStyles._();

  static TextStyle dayName(BuildContext context, {required bool isToday}) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: CalendarSizes.dayNameFontSize,
      color: isToday
          ? CalendarColors.todayHeaderText(context)
          : CalendarColors.normalDayName(context),
    );
  }

  static TextStyle dayNumber(BuildContext context, {required bool isToday}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: CalendarSizes.dayNumberFontSize,
      color: isToday
          ? CalendarColors.todayHeaderText(context)
          : CalendarColors.normalDayNumber(context),
    );
  }

  static TextStyle hourLabel(BuildContext context) {
    return TextStyle(
      fontSize: CalendarSizes.hourFontSize,
      color: CalendarColors.hourText(context),
    );
  }

  static const TextStyle appointmentTime = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: CalendarSizes.appointmentTimeFontSize,
  );

  static const TextStyle appointmentPatient = TextStyle(
    fontSize: CalendarSizes.appointmentPatientFontSize,
  );

  static const TextStyle appointmentSecondary = TextStyle(
    fontSize: CalendarSizes.appointmentSecondaryFontSize,
    color: Colors.black54,
  );

  static const TextStyle fabMenuLabel = TextStyle(
    fontSize: CalendarSizes.fabMenuLabelFontSize,
  );
}

class CalendarSizes {
  const CalendarSizes._();

  // Layout
  static const double hourHeight = 60;
  static const double timeColumnWidth = 56;

  // Calendar range
  static const int startHour = 0;
  static const int endHour = 24;

  // Header
  static const double headerVerticalPadding = 10;
  static const double dayNameFontSize = 11;
  static const double dayNumberFontSize = 16;

  // Grid
  static const double dividerWidth = 0.5;
  static const double hourFontSize = 11;
  static const double hourRightPadding = 8;
  static const double hourTopPadding = 2;

  // Appointment card
  static const double appointmentCardMarginBottom = 4;
  static const double appointmentCardPadding = 6;
  static const double appointmentTimeFontSize = 12;
  static const double appointmentPatientFontSize = 11;
  static const double appointmentSecondaryFontSize = 10;

  // Positioned appointment
  static const double appointmentHorizontalInset = 4;

  // FAB
  static const double fabBottom = 20;
  static const double fabRight = 16;
  static const double fabMenuSpacing = 8;
  static const double fabLabelHorizontalPadding = 10;
  static const double fabLabelVerticalPadding = 6;
  static const double fabLabelBorderRadius = 20;
  static const double fabLabelShadowBlur = 4;
  static const double fabMenuLabelFontSize = 13;
  static const double fabIconSize = 18;
}

class CalendarDurations {
  const CalendarDurations._();

  static const Duration fabRotation = Duration(milliseconds: 200);
}

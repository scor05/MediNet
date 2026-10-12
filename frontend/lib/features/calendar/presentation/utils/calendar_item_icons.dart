import 'package:flutter/material.dart';
import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';

IconData calendarItemIcon(SecretaryCalendarItemType type) => switch (type) {
  SecretaryCalendarItemType.appointment => Icons.event_available_outlined,
  SecretaryCalendarItemType.blockade => Icons.block_outlined,
  SecretaryCalendarItemType.schedule => Icons.schedule_outlined,
};

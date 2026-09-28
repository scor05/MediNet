String formatTime24(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return value;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return value;

  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

String calculateEndTime24(String startTime, int durationMinutes) {
  final parts = startTime.split(':');
  if (parts.length < 2) return startTime;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return startTime;

  final totalMinutes = (hour * 60 + minute + durationMinutes) % (24 * 60);
  final endHour = totalMinutes ~/ 60;
  final endMinute = totalMinutes % 60;

  return '${endHour.toString().padLeft(2, '0')}:'
      '${endMinute.toString().padLeft(2, '0')}';
}

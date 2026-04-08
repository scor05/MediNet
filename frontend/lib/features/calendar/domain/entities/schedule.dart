class Schedule {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int duration;
  final String clinicName;

  const Schedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.clinicName,
  });
}

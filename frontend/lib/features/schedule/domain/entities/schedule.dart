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

  Schedule copyWith({
    int? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? duration,
    String? clinicName,
  }) {
    return Schedule(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      clinicName: clinicName ?? this.clinicName,
    );
  }
}

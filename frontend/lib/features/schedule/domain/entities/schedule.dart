class Schedule {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int duration;
  final int doctorId;
  final String doctorName;
  final int clinicId;
  final String clinicName;

  const Schedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.doctorId = 0,
    this.doctorName = '',
    this.clinicId = 0,
    required this.clinicName,
  });

  Schedule copyWith({
    int? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? duration,
    int? doctorId,
    String? doctorName,
    int? clinicId,
    String? clinicName,
  }) {
    return Schedule(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
    );
  }
}

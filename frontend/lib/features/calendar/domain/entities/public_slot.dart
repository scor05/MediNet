class PublicSlot {
  final int scheduleId;
  final String startTime;
  final String endTime;
  final bool isOccupied;
  final int doctorId;
  final String doctorName;
  final int clinicId;
  final String clinicName;

  const PublicSlot({
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
    required this.isOccupied,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.clinicName,
  });
}

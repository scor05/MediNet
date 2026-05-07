import 'package:flutter/material.dart';

class PublicCalendarScreen extends StatelessWidget {
  final int? doctorId;
  final int? clinicId;

  const PublicCalendarScreen({super.key, this.doctorId, this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Calendario público\nDoctor ID: $doctorId\nClínica ID: $clinicId',
        textAlign: TextAlign.center,
      ),
    );
  }
}

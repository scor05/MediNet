import 'package:flutter/material.dart';
import 'package:frontend/theme/calendar_theme.dart';

class DialogHandle extends StatelessWidget {
  const DialogHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: CalendarColors.dialogHandle,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

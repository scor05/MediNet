import 'package:flutter/material.dart';
import 'package:frontend/features/clinic/domain/entities/clinic.dart';
import 'package:frontend/theme/app_theme.dart';

class ClinicTile extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback onDelete;

  const ClinicTile({super.key, required this.clinic, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_hospital_outlined,
            color: AppTheme.accent,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              clinic.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

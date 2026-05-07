import 'package:flutter/material.dart';

class ClientDetailEmptyState extends StatelessWidget {
  final String label;

  const ClientDetailEmptyState({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(color: Colors.black45, fontSize: 14),
      ),
    );
  }
}

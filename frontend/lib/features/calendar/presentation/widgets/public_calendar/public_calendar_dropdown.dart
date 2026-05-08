import 'package:flutter/material.dart';

class PublicCalendarDropdown extends StatelessWidget {
  final String label;
  final int? value;
  final String allLabel;
  final Map<int, String> options;
  final ValueChanged<int?> onChanged;

  const PublicCalendarDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.allLabel,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validValue = options.containsKey(value) ? value : null;

    return DropdownButtonFormField<int?>(
      initialValue: validValue,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<int?>(value: null, child: Text(allLabel)),
        ...options.entries.map(
          (entry) => DropdownMenuItem<int?>(
            value: entry.key,
            child: Text(entry.value, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

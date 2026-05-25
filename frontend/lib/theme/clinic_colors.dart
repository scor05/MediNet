import 'package:flutter/material.dart';

const List<Color> _clinicPalette = [
  Color(0xFF4A90D9),
  Color(0xFF7B68EE),
  Color(0xFF50C878),
  Color(0xFFFF8C42),
  Color(0xFFE75480),
  Color(0xFF20B2AA),
  Color(0xFFFFD700),
  Color(0xFFCD5C5C),
];

final Map<String, Color> _clinicColorCache = {};
int _nextIndex = 0;

Color getClinicColor(String clinicName) {
  if (!_clinicColorCache.containsKey(clinicName)) {
    _clinicColorCache[clinicName] =
        _clinicPalette[_nextIndex % _clinicPalette.length];
    _nextIndex++;
  }
  return _clinicColorCache[clinicName]!;
}
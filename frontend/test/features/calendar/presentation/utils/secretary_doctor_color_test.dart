import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/utils/secretary_doctor_color.dart';

void main() {
  test('generated colors stay in range and exclude strongly dominant reds', () {
    final random = Random(42);

    for (var index = 0; index < 500; index++) {
      final color = generateSecretaryDoctorColor(random);
      expect(isAllowedSecretaryDoctorColor(color), isTrue);
    }
  });

  test('allows pink but rejects a strongly red-dominant color', () {
    expect(
      isAllowedSecretaryDoctorColor(const Color.fromARGB(255, 180, 140, 165)),
      isTrue,
    );
    expect(
      isAllowedSecretaryDoctorColor(const Color.fromARGB(255, 180, 100, 100)),
      isFalse,
    );
  });
}

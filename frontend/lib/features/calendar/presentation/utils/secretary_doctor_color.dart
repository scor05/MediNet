import 'dart:math';

import 'package:flutter/material.dart';

const secretaryDoctorColorMinimum = 100;
const secretaryDoctorColorMaximum = 190;

Color generateSecretaryDoctorColor(
  Random random, {
  Iterable<Color> assignedColors = const [],
}) {
  for (var attempt = 0; attempt < 200; attempt++) {
    final candidate = Color.fromARGB(
      255,
      _channel(random),
      _channel(random),
      _channel(random),
    );
    if (!isAllowedSecretaryDoctorColor(candidate)) continue;
    if (assignedColors.any(
      (color) => color.toARGB32() == candidate.toARGB32(),
    )) {
      continue;
    }
    return candidate;
  }

  return Color.fromARGB(255, _channel(random), 190, 190);
}

bool isAllowedSecretaryDoctorColor(Color color) {
  final red = (color.r * 255).round();
  final green = (color.g * 255).round();
  final blue = (color.b * 255).round();
  final channelsInRange =
      red >= secretaryDoctorColorMinimum &&
      red <= secretaryDoctorColorMaximum &&
      green >= secretaryDoctorColorMinimum &&
      green <= secretaryDoctorColorMaximum &&
      blue >= secretaryDoctorColorMinimum &&
      blue <= secretaryDoctorColorMaximum;

  return channelsInRange && !(red > green + 40 && red > blue + 40);
}

int _channel(Random random) =>
    secretaryDoctorColorMinimum +
    random.nextInt(
      secretaryDoctorColorMaximum - secretaryDoctorColorMinimum + 1,
    );

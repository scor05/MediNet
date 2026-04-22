import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/schedule/data/models/schedule_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleRemoteDatasource {
  // Se devuelven todos los horarios del doctor logueado
  Future<List<ScheduleModel>> getDoctorSchedules() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/schedules/doctor/me'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  // Se crea un horario
  Future<ScheduleModel> createSchedule({
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/schedules'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'id_clinic': clinicId,
            'day_of_week': dayOfWeek,
            'start_time': _fmtTime(startTime),
            'end_time': _fmtTime(endTime),
            'duration': duration,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ScheduleModel.fromJson(data);
    } else {
      throw handleApiError(response);
    }
  }
}

/*
-------------------------------------- Helpers ----------------------------------------- 
*/

String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/schedule_blockade/data/models/schedule_blockade_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleBlockadeRemoteDatasource {
  Future<ScheduleBlockadeModel> createBlockade({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/schedule-blockades'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'id_schedule': scheduleId,
            'date': _fmtDate(date),
            'start_time': _fmtTime(startTime),
            'end_time': _fmtTime(endTime),
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ScheduleBlockadeModel.fromJson(data);
    } else {
      throw handleApiError(response);
    }
  }
}

String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

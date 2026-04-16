import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import '../models/schedule_model.dart';
import 'package:frontend/core/network/api_exception_handler.dart';

class ScheduleRemoteDatasource {
  Future<List<ScheduleModel>> getDoctorSchedules() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/schedules/me'),
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

  Future<ScheduleModel> createSchedule({
    required int idClinic,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
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
            'id_clinic': idClinic,
            'day_of_week': dayOfWeek,
            'start_time': startTime,
            'end_time': endTime,
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

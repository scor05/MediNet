import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import '../models/schedule_model.dart';

class ScheduleRemoteDatasource {
  Future<List<ScheduleModel>> getDoctorSchedules() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    
    // Asumiendo que el backend maneja "me" correctamente
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/users/me/schedules'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener los horarios.');
    }
  }

  Future<void> createSchedule({
    required int idClinic,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int duration,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/schedules'),
      headers: {
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
    );

    if (response.statusCode != 201) {
      String msg = 'Error al crear el horario.';
      try {
        final body = jsonDecode(response.body);
        if (body['error'] != null) {
          msg = body['error'];
        } else if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          msg = errors.values.first[0].toString();
        } else if (body['message'] != null) {
          msg = body['message'];
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}

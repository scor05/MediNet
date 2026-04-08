import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import '../models/appointment_model.dart';

class AppointmentRemoteDatasource {
  Future<List<AppointmentModel>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final queryParams = <String, String>{};
    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom.toIso8601String().substring(0, 10);
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo.toIso8601String().substring(0, 10);
    }

    final uri = Uri.parse(
      '${AppConfig.apiUrl}/calendar/doctor',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AppointmentModel.fromJson(e)).toList();
    } else {
      String errorMessage = 'Error al obtener el calendario.';
      try {
        final body = jsonDecode(response.body);
        if (body['error'] != null) errorMessage = body['error'];
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<AppointmentModel> createAppointment({
    required int idSchedule,
    required String date,
    required String startTime,
    required String patientName,
    required String status,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    // userId is not needed anymore as backend resolves it automatically based on backend fixes

    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/appointments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id_schedule': idSchedule,
        'date': date,
        'start_time': startTime,
        'name_patient': patientName,
        'status': status,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AppointmentModel.fromJson(data);
    } else {
      String msg = 'Error al agendar la cita.';
      try {
        final b = jsonDecode(response.body);
        if (b['error'] != null) {
          msg = b['error'];
        } else if (b['errors'] != null) {
          final errors = b['errors'] as Map<String, dynamic>;
          msg = errors.values.first[0].toString();
        } else if (b['message'] != null) {
          msg = b['message'];
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import '../models/appointment_model.dart';
import 'package:frontend/core/network/api_exception_handler.dart';

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

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AppointmentModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
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

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/appointments'),
          headers: {
            'Accept': 'application/json',
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
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AppointmentModel.fromJson(data);
    } else {
      throw handleApiError(response);
    }
  }

  Future<List<AppointmentModel>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final queryParams = <String, String>{};
    if (dateFrom != null) queryParams['date_from'] = dateFrom.toIso8601String().substring(0, 10);
    if (dateTo != null) queryParams['date_to'] = dateTo.toIso8601String().substring(0, 10);
    if (doctorId != null) queryParams['doctor_id'] = doctorId.toString();
    if (clinicId != null) queryParams['clinic_id'] = clinicId.toString();

    final uri = Uri.parse('${AppConfig.apiUrl}/calendar/secretary').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AppointmentModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }
}

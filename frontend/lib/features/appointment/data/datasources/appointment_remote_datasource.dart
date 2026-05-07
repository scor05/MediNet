import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/appointment/data/models/appointment_model.dart';
import 'package:frontend/features/appointment/data/models/public_appointment_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentRemoteDatasource {
  // Obtiene las citas de un doctor
  Future<List<AppointmentModel>> getDoctorAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? clientId,
    int? clinicId,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final queryParams = <String, String>{};
    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom.toIso8601String().substring(0, 10);
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo.toIso8601String().substring(0, 10);
    }
    if (clientId != null) {
      queryParams['client_id'] = clientId.toString();
    }
    if (clinicId != null) {
      queryParams['clinic_id'] = clinicId.toString();
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

  // Obtiene las citas de una secretaria
  Future<List<AppointmentModel>> getSecretaryAppointments({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? doctorId,
    int? clinicId,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final queryParams = <String, String>{};
    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom.toIso8601String().substring(0, 10);
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo.toIso8601String().substring(0, 10);
    }
    if (doctorId != null) {
      queryParams['doctor_id'] = doctorId.toString();
    }
    if (clinicId != null) {
      queryParams['clinic_id'] = clinicId.toString();
    }

    final uri = Uri.parse(
      '${AppConfig.apiUrl}/calendar/secretary',
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

  // Obtiene las citas de un paciente
  Future<List<AppointmentModel>> getPatientAppointments({
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
      '${AppConfig.apiUrl}/calendar/patient',
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

  // Crea una cita
  Future<AppointmentModel> createAppointment({
    required int scheduleId,
    required DateTime date,
    required TimeOfDay startTime,
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
            'id_schedule': scheduleId,
            'date': date.toIso8601String().substring(0, 10),
            'start_time': _fmtTime(startTime),
            'name_patient': patientName,
            'status': status,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AppointmentModel.fromCreation(data);
    } else {
      throw handleApiError(response);
    }
  }

  // Obtiene las citas de públicas de un doctor o clínica
  Future<List<PublicAppointmentModel>> getPublicAppointments({
    int? doctorId,
    int? clinicId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final queryParameters = <String, String>{};

    if (doctorId != null) {
      queryParameters['doctor_id'] = doctorId.toString();
    }

    if (clinicId != null) {
      queryParameters['clinic_id'] = clinicId.toString();
    }

    if (dateFrom != null) {
      queryParameters['date_from'] = dateFrom.toIso8601String().substring(
        0,
        10,
      );
    }

    if (dateTo != null) {
      queryParameters['date_to'] = dateTo.toIso8601String().substring(0, 10);
    }

    final uri = Uri.parse(
      '${AppConfig.apiUrl}/calendar/public',
    ).replace(queryParameters: queryParameters);

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

      return data
          .map(
            (item) =>
                PublicAppointmentModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw handleApiError(response);
    }
  }

  /*
  -------------------------------------- Helpers ----------------------------------------- 
  */

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

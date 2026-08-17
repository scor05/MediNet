import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/waitlist/data/models/waitlist_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class WaitlistRemoteDatasource {
  static const _defaultTimeout = Duration(seconds: 10);

  // Obtiene los waitlists de un paciente
  Future<List<WaitlistModel>> getPatientWaitlists(int patientId) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final uri = Uri.parse('${AppConfig.apiUrl}/waitlists/patient/$patientId');

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(_defaultTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => WaitlistModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  // Crea un nuevo waitlist
  Future<WaitlistModel> createWaitlist({
    required int patientId,
    required int targetAppointmentId,
    required int fallbackAppointmentId,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/waitlists'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'id_patient': patientId,
            'id_target_appointment': targetAppointmentId,
            'id_fallback_appointment': fallbackAppointmentId,
            'status': 'active',
          }),
        )
        .timeout(_defaultTimeout);

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return WaitlistModel.fromJson(data);
    } else {
      throw handleApiError(response);
    }
  }

  // Cancela un waitlist (actualiza status a 'cancelled')
  Future<void> cancelWaitlist(int waitlistId) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .patch(
          Uri.parse('${AppConfig.apiUrl}/waitlists/$waitlistId'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'status': 'cancelled'}),
        )
        .timeout(_defaultTimeout);

    if (response.statusCode != 200) {
      throw handleApiError(response);
    }
  }
}

import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/patient_profile/data/models/patient_profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientProfileRemoteDatasource {
  final _supabase = Supabase.instance.client;

  // Obtiene el perfil del paciente autenticado
  Future<PatientProfileModel> getPatientProfile() async {
    final token = _supabase.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/patient/profile'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw handleApiError(response);
    }
  }

  // Actualiza name y/o phone del perfil del paciente
  Future<PatientProfileModel> updatePatientProfile({
    String? name,
    String? phone,
  }) async {
    final token = _supabase.auth.currentSession?.accessToken;

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;

    final response = await http
        .put(
          Uri.parse('${AppConfig.apiUrl}/patient/profile'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw handleApiError(response);
    }
  }
}

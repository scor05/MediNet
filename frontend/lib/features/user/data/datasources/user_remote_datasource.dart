import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/services/firebase_support_service.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/user/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/features/user/data/models/patient_profile_model.dart';

class UserRemoteDatasource {
  // Se obtienen todos los usuarios que no son superadmins
  Future<List<UserModel>> getAvailableUsers(String search) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse(
            '${AppConfig.apiUrl}/users/available?search=${Uri.encodeComponent(search)}',
          ),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromSearch(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  // Guarda el token FCM del usuario
  Future<void> saveFcmToken() async {
    if (!FirebaseSupportService.supportsMessaging) return;

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) return;

    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/users/fcm-token'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'fcm_token': fcmToken}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw handleApiError(response);
    }
  }

  // Obtiene el perfil básico del paciente autenticado
  Future<PatientProfileModel> getPatientProfile() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/patient/profile'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(jsonDecode(response.body));
    } else {
      throw handleApiError(response);
    }
  }

  // Obtiene datos básicos de un paciente (para secretarias autorizadas)
  Future<Map<String, dynamic>> getPatientBasicInfo(int patientId) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/users/$patientId/patient-info'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw handleApiError(response);
    }
  }
}

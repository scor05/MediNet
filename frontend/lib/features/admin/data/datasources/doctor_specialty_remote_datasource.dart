import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/admin/domain/entities/doctor_specialty.dart';
import 'package:frontend/features/admin/domain/entities/specialty.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorSpecialtyRemoteDatasource {
  Map<String, String> _headers() {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Specialty>> getSpecialties() async {
    final response = await http
        .get(Uri.parse('${AppConfig.apiUrl}/specialties'), headers: _headers())
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => Specialty.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw handleApiError(response);
  }

  Future<List<DoctorSpecialty>> getDoctorSpecialties(int doctorId) async {
    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/users/$doctorId/specialties'),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => DoctorSpecialty.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw handleApiError(response);
  }

  Future<void> addDoctorSpecialty({
    required int doctorId,
    required int specialtyId,
  }) async {
    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/users/$doctorId/specialties'),
          headers: _headers(),
          body: jsonEncode({'id_specialty': specialtyId}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      throw handleApiError(response);
    }
  }

  Future<Specialty> createSpecialty(String name) async {
    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/specialties'),
          headers: _headers(),
          body: jsonEncode({'specialty': name}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Specialty.fromJson(data);
    }

    throw handleApiError(response);
  }

  Future<void> deleteDoctorSpecialty({
    required int doctorId,
    required int specialtyId,
  }) async {
    final response = await http
        .delete(
          Uri.parse(
            '${AppConfig.apiUrl}/users/$doctorId/specialties/$specialtyId',
          ),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 204) {
      throw handleApiError(response);
    }
  }
}

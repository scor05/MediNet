import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import '../models/clinic_model.dart';
import 'package:frontend/core/network/api_exception_handler.dart';

class ClinicRemoteDatasource {
  Future<List<ClinicModel>> getClinics() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/clinics'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ClinicModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  Future<ClinicModel> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/clinics'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': name,
            'address': address,
            'phone': phone,
            'email': email,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ClinicModel.fromJson(data);
    } else {
      throw handleApiError(response);
    }
  }
}

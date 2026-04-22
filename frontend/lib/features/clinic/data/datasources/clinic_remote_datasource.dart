import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/clinic/data/models/clinic_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicRemoteDatasource {
  // Se obtienen las clínicas del cliente
  Future<List<ClinicModel>> getClinics(int? clientId) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    late final http.Response response;

    if (clientId == null) {
      response = await http
          .get(
            Uri.parse('${AppConfig.apiUrl}/clinics'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));
    } else {
      response = await http
          .get(
            Uri.parse('${AppConfig.apiUrl}/clients/$clientId/clinics'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ClinicModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  // Se crea una nueva clínica
  Future<ClinicModel> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
    required int clientId,
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
            'client_id': clientId,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return ClinicModel.fromJson(jsonDecode(response.body));
    } else {
      throw handleApiError(response);
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import '../models/clinic_model.dart';

class ClinicRemoteDatasource {
  Future<List<ClinicModel>> getClinics() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/clinics'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ClinicModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener las clínicas.');
    }
  }

  Future<void> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/clinics'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
      }),
    );

    if (response.statusCode != 201) {
      String msg = 'Error al crear la clínica.';
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

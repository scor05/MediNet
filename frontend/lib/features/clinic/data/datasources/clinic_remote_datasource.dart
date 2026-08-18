import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/clinic/data/models/clinic_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicRemoteDatasource {
  // Se obtienen las clínicas del cliente
  Future<List<ClinicModel>> getClinics(int? clientId) async {
    final headers = await _authenticatedHeaders();

    late final http.Response response;

    if (clientId == null) {
      response = await http
          .get(Uri.parse('${AppConfig.apiUrl}/clinics'), headers: headers)
          .timeout(const Duration(seconds: 10));
    } else {
      response = await http
          .get(
            Uri.parse('${AppConfig.apiUrl}/clients/$clientId/clinics'),
            headers: headers,
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
    final headers = await _authenticatedHeaders();

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/clinics'),
          headers: headers,
          body: jsonEncode({
            'name': name,
            'address': address,
            'phone': phone,
            'email': email,
            'id_client': clientId,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return ClinicModel.fromJson(jsonDecode(response.body));
    } else {
      throw handleApiError(response);
    }
  }

  Future<void> deleteClinic(int clinicId) async {
    final headers = await _authenticatedHeaders(includeContentType: false);

    final response = await http
        .delete(
          Uri.parse('${AppConfig.apiUrl}/clinics/$clinicId'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 204) {
      throw handleApiError(response);
    }
  }

  Future<Map<String, String>> _authenticatedHeaders({
    bool includeContentType = true,
  }) async {
    final auth = Supabase.instance.client.auth;
    var session = auth.currentSession;

    if (session == null) {
      throw ApiException(
        'Tu sesión expiró. Inicia sesión nuevamente.',
        statusCode: 401,
      );
    }

    if (session.isExpired) {
      try {
        session = (await auth.refreshSession()).session;
      } catch (_) {
        throw ApiException(
          'No se pudo renovar tu sesión. Inicia sesión nuevamente.',
          statusCode: 401,
        );
      }
    }

    if (session == null) {
      throw ApiException(
        'Tu sesión expiró. Inicia sesión nuevamente.',
        statusCode: 401,
      );
    }

    return {
      'Accept': 'application/json',
      if (includeContentType) 'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }
}

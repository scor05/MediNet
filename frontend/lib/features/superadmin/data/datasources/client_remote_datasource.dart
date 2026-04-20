import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import '../models/client_model.dart';

class ClientRemoteDatasource {
  Future<List<ClientModel>> getClients() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/clients'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ClientModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  Future<ClientModel> toggleClientStatus(int id, bool isActive) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .patch(
          Uri.parse('${AppConfig.apiUrl}/clients/$id'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'is_active': isActive}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ClientModel.fromJson(data);
    } else {
      throw handleApiError(response);
    }
  }

  Future<ClientModel> createClient({
    required String name,
    required String nit,
    int? userId,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/clients'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'name': name, 'nit': nit, 'id_user': userId}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return ClientModel.fromJson(jsonDecode(response.body));
    } else {
      throw handleApiError(response);
    }
  }

  Future<ClientModel> editClient(
    int id, {
    required String name,
    required String nit,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .patch(
          Uri.parse('${AppConfig.apiUrl}/clients/$id'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'name': name, 'nit': nit}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ClientModel.fromJson(jsonDecode(response.body));
    } else {
      throw handleApiError(response);
    }
  }
}

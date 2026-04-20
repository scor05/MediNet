import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import '../models/user_model.dart';

class UserRemoteDatasource {
  // Se obtienen los usuarios del cliente
  Future<List<UserModel>> getClientUsers(int clientId) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/clients/$clientId/users'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromClientUserJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  // Se agrega un usuario a un cliente
  Future<void> addUserToClient(
    int clientId,
    int userId,
    int role,
    bool isAdmin,
  ) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/clients/$clientId/users'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'id_user': userId,
            'role': role,
            'is_admin': isAdmin,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      throw handleApiError(response);
    }
  }

  // Se obtiene los usuarios que no están asociados ya al cliente y que no son superadmins
  Future<List<UserModel>> getAvailableUsersForClient(
    int clientId,
    String search,
  ) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse(
            '${AppConfig.apiUrl}/users/available/$clientId?search=${Uri.encodeComponent(search)}',
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
      return data.map((e) => UserModel.fromAvailableUserJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }
}

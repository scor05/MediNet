import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/client/data/models/client_model.dart';
import 'package:frontend/features/client/data/models/client_user_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientRemoteDatasource {
  /*
  ---------------------------------------- Clientes ---------------------------------------
  */

  // Obtiene todos los clientes
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

  // Cambia el estado de un cliente
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

  // Crea un nuevo cliente
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

  // Edita la informacion de un cliente
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

  /*
  ---------------------------------------- Usuarios de Clientes ---------------------------------------
  */

  // Se obtienen los usuarios del cliente
  Future<List<ClientUserModel>> getClientUsers(int clientId) async {
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
      return data.map((e) => ClientUserModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  // Se agrega un usuario a un cliente
  Future<ClientUserModel> addUserToClient(
    int clientId,
    int userId,
    String role,
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
            'role': _mapRole(role),
            'is_admin': isAdmin,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return ClientUserModel.fromJson(jsonDecode(response.body));
    } else {
      throw handleApiError(response);
    }
  }

  // Edita un usuario de un cliente
  Future<ClientUserModel> editClientUser(
    int clientId,
    int userId,
    String role,
    bool isAdmin,
    bool isActive,
  ) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .patch(
          Uri.parse('${AppConfig.apiUrl}/clients/$clientId/users/$userId'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'role': _mapRole(role),
            'is_admin': isAdmin,
            'is_active': isActive,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ClientUserModel.fromJson(jsonDecode(response.body));
    } else {
      throw handleApiError(response);
    }
  }

  // Se obtiene los usuarios que no están asociados ya al cliente y que no son superadmins
  Future<List<ClientUserModel>> getAvailableUsersForClient(
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
      return data.map((e) => ClientUserModel.fromSearch(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }
}

/*
------------------------------------------ Helpers ------------------------------------------------
*/

int _mapRole(String role) {
  switch (role.toLowerCase()) {
    case 'administrador':
      return 0;
    case 'doctor':
      return 1;
    case 'secretaria':
      return 2;
    default:
      throw ArgumentError('Rol desconocido: $role');
  }
}

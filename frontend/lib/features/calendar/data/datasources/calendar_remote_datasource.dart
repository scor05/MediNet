import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/app_config.dart';
import '../models/appointment_model.dart';

class CalendarRemoteDatasource {
  Future<List<AppointmentModel>> getDoctorCalendar({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final queryParams = <String, String>{};
    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom.toIso8601String().substring(0, 10);
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo.toIso8601String().substring(0, 10);
    }

    final uri = Uri.parse(
      '${AppConfig.apiUrl}/calendar/doctor',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AppointmentModel.fromJson(e)).toList();
    } else {
      String errorMessage = 'Error al obtener el calendario.';
      try {
        final body = jsonDecode(response.body);
        if (body['error'] != null) errorMessage = body['error'];
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}

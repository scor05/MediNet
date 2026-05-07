import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/calendar/data/models/public_slot_model.dart';
import 'package:frontend/features/clinic/data/models/clinic_model.dart';
import 'package:frontend/features/user/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class PublicCalendarRemoteDatasource {
  // Obtiene los doctores disponibles para el calendario público
  Future<List<UserModel>> getDoctors({int? clinicId}) async {
    final queryParams = <String, String>{};
    if (clinicId != null) queryParams['clinic_id'] = clinicId.toString();

    final uri = Uri.parse(
      '${AppConfig.apiUrl}/public/doctors',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  // Obtiene las clínicas disponibles para el calendario público
  Future<List<ClinicModel>> getClinics({int? doctorId}) async {
    final queryParams = <String, String>{};
    if (doctorId != null) queryParams['doctor_id'] = doctorId.toString();

    final uri = Uri.parse(
      '${AppConfig.apiUrl}/public/clinics',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
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

  // Obtiene los slots disponibles para una fecha
  Future<List<PublicSlotModel>> getSlots({
    required int doctorId,
    required int clinicId,
    required DateTime date,
  }) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/public/slots').replace(
      queryParameters: {
        'doctor_id': doctorId.toString(),
        'clinic_id': clinicId.toString(),
        'date': date.toIso8601String().substring(0, 10),
      },
    );

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => PublicSlotModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }
}

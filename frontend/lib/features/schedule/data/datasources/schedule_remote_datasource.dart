import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/schedule/data/models/schedule_model.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleRemoteDatasource {
  // Se devuelven todos los horarios del doctor logueado
  Future<List<ScheduleModel>> getDoctorSchedules() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/schedules/doctor/me'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  // Se devuelven los horarios de un doctor por su ID
  Future<List<ScheduleModel>> getSchedulesByDoctorId(int doctorId) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/schedules/doctor/$doctorId'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    } else {
      throw handleApiError(response);
    }
  }

  Future<List<ScheduleModel>> getSecretarySchedules() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .get(
          Uri.parse('${AppConfig.apiUrl}/schedules/secretary'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    }

    throw handleApiError(response);
  }

  // Se crea un horario
  Future<ScheduleModel> createSchedule({
    int? doctorId,
    required int clinicId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final response = await http
        .post(
          Uri.parse('${AppConfig.apiUrl}/schedules'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'id_doctor': ?doctorId,
            'id_clinic': clinicId,
            'day_of_week': dayOfWeek,
            'start_time': _fmtTime(startTime),
            'end_time': _fmtTime(endTime),
            'duration': duration,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ScheduleModel.fromJson(data);
    } else {
      throw handleApiError(response);
    }
  }

  Future<ScheduleModel> updateSchedule({
    required int id,
    required int clinicId,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int duration,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final response = await http
        .put(
          Uri.parse('${AppConfig.apiUrl}/schedules/$id'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'id_clinic': clinicId,
            'start_time': _fmtTime(startTime),
            'end_time': _fmtTime(endTime),
            'duration': duration,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ScheduleModel.fromJson(jsonDecode(response.body));
    }
    throw handleApiError(response);
  }

  Future<void> deleteSchedule(int id) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final response = await http
        .delete(
          Uri.parse('${AppConfig.apiUrl}/schedules/$id'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 204) throw handleApiError(response);
  }
}

/*
-------------------------------------- Helpers ----------------------------------------- 
*/

String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

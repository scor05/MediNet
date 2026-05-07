import 'dart:convert';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/network/api_exception_handler.dart';
import 'package:frontend/features/search/data/models/search_result_model.dart';
import 'package:frontend/features/search/domain/entities/search_result.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRemoteDatasource {
  Future<SearchResult> search(String query) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final uri = Uri.parse(
      '${AppConfig.apiUrl}/search',
    ).replace(queryParameters: {'q': query});

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return SearchResultModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw handleApiError(response);
    }
  }
}

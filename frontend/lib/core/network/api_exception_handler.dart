import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/exceptions/api_exception.dart';

void handleApiError(http.Response response) {
  final body = jsonDecode(response.body);

  // Para errores 422
  if (body['errors'] != null && body['errors'] is Map) {
    final errors = body['errors'] as Map<String, dynamic>;
    final firstField = errors.values.first;
    if (firstField is List && firstField.isNotEmpty) {
      throw ApiException(
        firstField[0].toString(),
        statusCode: response.statusCode,
      );
    }
  }

  // Para otros errores
  throw ApiException(
    body['message'] ?? body['error'] ?? 'Error inesperado.',
    statusCode: response.statusCode,
  );
}

import 'dart:async';
import 'dart:io';

import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/features/search/data/datasources/search_remote_datasource.dart';
import 'package:frontend/features/search/domain/entities/search_result.dart';
import 'package:frontend/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDatasource datasource;

  SearchRepositoryImpl(this.datasource);

  @override
  Future<SearchResult> search(String query) async {
    try {
      return await datasource.search(query);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on TimeoutException {
      throw ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (_) {
      throw ApiException('Error inesperado. Intenta de nuevo.');
    }
  }
}

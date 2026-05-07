import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/search/data/datasources/search_remote_datasource.dart';
import 'package:frontend/features/search/data/repositories/search_repository_impl.dart';
import 'package:frontend/features/search/domain/repositories/search_repository.dart';

final searchRemoteDatasourceProvider = Provider((ref) {
  return SearchRemoteDatasource();
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(ref.read(searchRemoteDatasourceProvider));
});

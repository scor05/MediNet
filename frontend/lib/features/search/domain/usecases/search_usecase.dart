import 'package:frontend/features/search/domain/entities/search_result.dart';
import 'package:frontend/features/search/domain/repositories/search_repository.dart';

class SearchUsecase {
  final SearchRepository repository;

  SearchUsecase(this.repository);

  Future<SearchResult> call(String query) {
    return repository.search(query);
  }
}

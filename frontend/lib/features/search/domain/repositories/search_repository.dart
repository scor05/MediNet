import 'package:frontend/features/search/domain/entities/search_result.dart';

abstract class SearchRepository {
  Future<SearchResult> search(String query);
}

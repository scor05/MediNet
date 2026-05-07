import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/search/data/providers/search_data_providers.dart';
import 'package:frontend/features/search/domain/usecases/search_usecase.dart';

final searchUsecaseProvider = Provider((ref) {
  return SearchUsecase(ref.read(searchRepositoryProvider));
});

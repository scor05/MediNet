import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/user/data/providers/user_data_providers.dart';
import 'package:frontend/features/user/domain/usecases/get_available_users_usecase.dart';

// Provider para el usecase getAvailableUsers
final getAvailableUsersUsecaseProvider = Provider((ref) {
  return GetAvailableUsersUsecase(ref.read(userRepositoryProvider));
});

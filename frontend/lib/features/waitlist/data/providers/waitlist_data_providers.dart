import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/waitlist/data/datasources/waitlist_remote_datasource.dart';
import 'package:frontend/features/waitlist/data/repositories/waitlist_repository_impl.dart';
import 'package:frontend/features/waitlist/domain/repositories/waitlist_repository.dart';

// Provider para el datasource de waitlists
final waitlistRemoteDatasourceProvider = Provider((ref) {
  return WaitlistRemoteDatasource();
});

// Provider para la implementación del repository de waitlists
final waitlistRepositoryProvider = Provider<WaitlistRepository>((ref) {
  return WaitlistRepositoryImpl(
    ref.read(waitlistRemoteDatasourceProvider),
    ref.read(getProfileUsecaseProvider),
  );
});

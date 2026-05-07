import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/calendar/data/datasources/public_calendar_remote_datasource.dart';
import 'package:frontend/features/calendar/data/repositories/public_calendar_repository_impl.dart';
import 'package:frontend/features/calendar/domain/repositories/public_calendar_repository.dart';

// Provider para el datasource del calendario público
final publicCalendarRemoteDatasourceProvider = Provider((ref) {
  return PublicCalendarRemoteDatasource();
});

// Provider para la implementacion del repository del calendario público
final publicCalendarRepositoryProvider = Provider<PublicCalendarRepository>((
  ref,
) {
  return PublicCalendarRepositoryImpl(
    ref.read(publicCalendarRemoteDatasourceProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/schedule/data/datasources/schedule_remote_datasource.dart';
import 'package:frontend/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:frontend/features/schedule/domain/repositories/schedule_repository.dart';

// Provider para el datasource de horarios
final scheduleRemoteDatasourceProvider = Provider((ref) {
  return ScheduleRemoteDatasource();
});

// Provider para la implementacion del repository de horarios
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepositoryImpl(ref.read(scheduleRemoteDatasourceProvider));
});

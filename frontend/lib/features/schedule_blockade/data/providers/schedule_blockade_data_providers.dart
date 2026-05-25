import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/schedule_blockade/data/datasources/schedule_blockade_remote_datasource.dart';
import 'package:frontend/features/schedule_blockade/data/repositories/schedule_blockade_repository_impl.dart';
import 'package:frontend/features/schedule_blockade/domain/repositories/schedule_blockade_repository.dart';

final scheduleBlockadeRemoteDatasourceProvider = Provider((ref) {
  return ScheduleBlockadeRemoteDatasource();
});

final scheduleBlockadeRepositoryProvider =
    Provider<ScheduleBlockadeRepository>((ref) {
  return ScheduleBlockadeRepositoryImpl(
    ref.read(scheduleBlockadeRemoteDatasourceProvider),
  );
});

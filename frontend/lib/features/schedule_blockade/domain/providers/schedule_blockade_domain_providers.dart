import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/schedule_blockade/data/providers/schedule_blockade_data_providers.dart';
import 'package:frontend/features/schedule_blockade/domain/usecases/create_schedule_blockade_usecase.dart';

final createScheduleBlockadeUsecaseProvider = Provider((ref) {
  return CreateScheduleBlockadeUsecase(
    ref.read(scheduleBlockadeRepositoryProvider),
  );
});

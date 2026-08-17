import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/waitlist/data/providers/waitlist_data_providers.dart';
import 'package:frontend/features/waitlist/domain/usecases/cancel_waitlist_usecase.dart';
import 'package:frontend/features/waitlist/domain/usecases/create_waitlist_usecase.dart';
import 'package:frontend/features/waitlist/domain/usecases/get_patient_waitlists_usecase.dart';

// Provider para el usecase getPatientWaitlists
final getPatientWaitlistsUsecaseProvider = Provider((ref) {
  return GetPatientWaitlistsUsecase(ref.read(waitlistRepositoryProvider));
});

// Provider para el usecase createWaitlist
final createWaitlistUsecaseProvider = Provider((ref) {
  return CreateWaitlistUsecase(ref.read(waitlistRepositoryProvider));
});

// Provider para el usecase cancelWaitlist
final cancelWaitlistUsecaseProvider = Provider((ref) {
  return CancelWaitlistUsecase(ref.read(waitlistRepositoryProvider));
});

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/realtime/patient_appointment_realtime_connection.dart';
import 'package:frontend/core/realtime/realtime_coordinator.dart';
import 'package:frontend/features/calendar/presentation/providers/patient_calendar_provider.dart';
import 'package:frontend/features/waitlist/presentation/providers/waitlist_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef PatientAppointmentRealtimeConnectionFactory =
    PatientAppointmentRealtimeConnection Function(int patientId);

final patientAppointmentRealtimeConnectionFactoryProvider =
    Provider<PatientAppointmentRealtimeConnectionFactory>((ref) {
      return (patientId) => ReverbPatientAppointmentConnection(
        patientId: patientId,
        host: AppConfig.reverbHost,
        port: AppConfig.reverbPort,
        scheme: AppConfig.reverbScheme,
        appKey: AppConfig.reverbAppKey,
        authorizationEndpoint: AppConfig.broadcastingAuthUrl,
        supabase: Supabase.instance.client,
      );
    });

final patientAppointmentRealtimeProvider = Provider.autoDispose
    .family<void, int>((ref, patientId) {
      final connectionFactory = ref.watch(
        patientAppointmentRealtimeConnectionFactoryProvider,
      );
      final coordinator = RealtimeCoordinator(
        connection: connectionFactory(patientId),
        onChanged: () async {
          await Future.wait([
            ref
                .read(patientCalendarNotifierProvider(patientId).notifier)
                .refreshAll(),
            ref.read(patientWaitlistNotifierProvider.notifier).refresh(),
          ]);
        },
      );

      unawaited(coordinator.start());
      ref.onDispose(() => unawaited(coordinator.dispose()));
    });

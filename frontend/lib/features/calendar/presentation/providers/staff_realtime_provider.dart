import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/core/realtime/realtime_connection.dart';
import 'package:frontend/core/realtime/realtime_coordinator.dart';
import 'package:frontend/core/realtime/staff_realtime_connection.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/doctor_requested_appointments_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_calendar_provider.dart';
import 'package:frontend/features/calendar/presentation/providers/secretary_requested_appointments_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StaffRealtimeRole { doctor, secretary }

class StaffRealtimeTarget {
  final StaffRealtimeRole role;
  final int userId;
  final List<int> clientIds;

  const StaffRealtimeTarget.doctor(int doctorId)
    : role = StaffRealtimeRole.doctor,
      userId = doctorId,
      clientIds = const [];

  StaffRealtimeTarget.secretary(int secretaryId, Iterable<int> clientIds)
    : role = StaffRealtimeRole.secretary,
      userId = secretaryId,
      clientIds = (clientIds.toSet().toList()..sort());

  List<String> get channelNames => switch (role) {
    StaffRealtimeRole.doctor => ['private-doctors.$userId'],
    StaffRealtimeRole.secretary => [
      for (final clientId in clientIds) 'private-organizations.$clientId',
    ],
  };

  @override
  bool operator ==(Object other) =>
      other is StaffRealtimeTarget &&
      other.role == role &&
      other.userId == userId &&
      _sameIds(other.clientIds, clientIds);

  @override
  int get hashCode => Object.hash(role, userId, Object.hashAll(clientIds));

  static bool _sameIds(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}

typedef StaffRealtimeConnectionFactory =
    RealtimeConnection Function(List<String> privateChannelNames);

final staffRealtimeConnectionFactoryProvider =
    Provider<StaffRealtimeConnectionFactory>((ref) {
      return (privateChannelNames) => ReverbStaffRealtimeConnection(
        privateChannelNames: privateChannelNames,
        host: AppConfig.reverbHost,
        port: AppConfig.reverbPort,
        scheme: AppConfig.reverbScheme,
        appKey: AppConfig.reverbAppKey,
        authorizationEndpoint: AppConfig.broadcastingAuthUrl,
        supabase: Supabase.instance.client,
      );
    });

final staffRealtimeProvider = Provider.autoDispose
    .family<void, StaffRealtimeTarget>((ref, target) {
      final connectionFactory = ref.watch(
        staffRealtimeConnectionFactoryProvider,
      );
      final coordinator = RealtimeCoordinator(
        connection: connectionFactory(target.channelNames),
        onChanged: () async {
          switch (target.role) {
            case StaffRealtimeRole.doctor:
              await Future.wait([
                ref.read(doctorCalendarNotifierProvider.notifier).refresh(),
                ref
                    .read(doctorRequestedAppointmentsNotifierProvider.notifier)
                    .refresh(),
              ]);
              break;
            case StaffRealtimeRole.secretary:
              await Future.wait([
                ref.read(secretaryCalendarNotifierProvider.notifier).refresh(),
                ref
                    .read(
                      secretaryRequestedAppointmentsNotifierProvider.notifier,
                    )
                    .refresh(),
              ]);
              break;
          }
        },
      );

      unawaited(coordinator.start());
      ref.onDispose(() => unawaited(coordinator.dispose()));
    });

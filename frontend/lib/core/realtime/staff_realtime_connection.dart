import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:frontend/core/realtime/patient_appointment_realtime_connection.dart';
import 'package:frontend/core/realtime/realtime_connection.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ReverbStaffRealtimeConnection implements RealtimeConnection {
  final List<String> privateChannelNames;
  final String host;
  final int port;
  final String scheme;
  final String appKey;
  final Uri authorizationEndpoint;
  final SupabaseClient supabase;

  final _changes = StreamController<void>.broadcast();
  final _httpClient = http.Client();
  final _eventSubscriptions = <StreamSubscription<ChannelReadEvent>>[];

  PusherChannelsClient? _client;
  StreamSubscription<void>? _connectionSubscription;
  Timer? _reconnectTimer;
  bool _started = false;
  bool _disposed = false;

  ReverbStaffRealtimeConnection({
    required this.privateChannelNames,
    required this.host,
    required this.port,
    required this.scheme,
    required this.appKey,
    required this.authorizationEndpoint,
    required this.supabase,
  });

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> connect() async {
    if (_started || _disposed || privateChannelNames.isEmpty) return;
    _started = true;

    final options = PusherChannelsOptions.fromHost(
      scheme: scheme,
      host: host,
      port: port,
      key: appKey,
    );
    final client = PusherChannelsClient.websocket(
      options: options,
      minimumReconnectDelayDuration: const Duration(seconds: 2),
      connectionErrorHandler: (_, _, reconnect) {
        _scheduleReconnect(reconnect);
      },
    );
    final authorizationDelegate = SupabasePrivateChannelAuthorizationDelegate(
      authorizationEndpoint: authorizationEndpoint,
      supabase: supabase,
      httpClient: _httpClient,
      onAuthFailed: (_, _) => _scheduleReconnect(() {
        unawaited(client.reconnect());
      }),
    );
    final channels = privateChannelNames
        .map(
          (name) => client.privateChannel(
            name,
            authorizationDelegate: authorizationDelegate,
          ),
        )
        .toList();

    _client = client;
    _connectionSubscription = client.onConnectionEstablished.listen((_) {
      for (final channel in channels) {
        channel.subscribeIfNotUnsubscribed();
      }
    });
    for (final channel in channels) {
      for (final eventName in const [
        'appointment.changed',
        'waitlist.changed',
      ]) {
        _eventSubscriptions.add(
          channel.bind(eventName).listen((_) {
            if (!_changes.isClosed) _changes.add(null);
          }),
        );
      }
    }

    await client.connect();
  }

  void _scheduleReconnect(void Function() reconnect) {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      if (!_disposed) reconnect();
    });
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _reconnectTimer?.cancel();
    for (final subscription in _eventSubscriptions) {
      await subscription.cancel();
    }
    await _connectionSubscription?.cancel();

    final client = _client;
    if (client != null && !client.isDisposed) {
      try {
        await client.disconnect();
      } catch (_) {
        // La conexión puede cerrarse antes que la pantalla de la sesión.
      } finally {
        client.dispose();
      }
    }

    _httpClient.close();
    await _changes.close();
  }
}

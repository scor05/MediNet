import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PatientAppointmentRealtimeConnection {
  Stream<void> get changes;

  Future<void> connect();

  Future<void> dispose();
}

class ReverbPatientAppointmentConnection
    implements PatientAppointmentRealtimeConnection {
  final int patientId;
  final String host;
  final int port;
  final String scheme;
  final String appKey;
  final Uri authorizationEndpoint;
  final SupabaseClient supabase;

  final _changes = StreamController<void>.broadcast();
  final _httpClient = http.Client();

  PusherChannelsClient? _client;
  StreamSubscription<void>? _connectionSubscription;
  StreamSubscription<ChannelReadEvent>? _eventSubscription;
  Timer? _reconnectTimer;
  bool _started = false;
  bool _disposed = false;

  ReverbPatientAppointmentConnection({
    required this.patientId,
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
    if (_started || _disposed) return;
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

    final channel = client.privateChannel(
      'private-patients.$patientId',
      authorizationDelegate: SupabasePrivateChannelAuthorizationDelegate(
        authorizationEndpoint: authorizationEndpoint,
        supabase: supabase,
        httpClient: _httpClient,
        onAuthFailed: (_, _) => _scheduleReconnect(() {
          unawaited(client.reconnect());
        }),
      ),
    );

    _client = client;
    _connectionSubscription = client.onConnectionEstablished.listen((_) {
      channel.subscribeIfNotUnsubscribed();
    });
    _eventSubscription = channel.bind('appointment.changed').listen((_) {
      if (!_changes.isClosed) _changes.add(null);
    });

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
    await _eventSubscription?.cancel();
    await _connectionSubscription?.cancel();

    final client = _client;
    if (client != null && !client.isDisposed) {
      try {
        await client.disconnect();
      } catch (_) {
        // La conexión puede haberse cerrado antes de desmontar la sesión.
      } finally {
        client.dispose();
      }
    }

    _httpClient.close();
    await _changes.close();
  }
}

class SupabasePrivateChannelAuthorizationDelegate
    implements
        EndpointAuthorizableChannelAuthorizationDelegate<
          PrivateChannelAuthorizationData
        > {
  final Uri authorizationEndpoint;
  final SupabaseClient supabase;
  final http.Client httpClient;

  @override
  final EndpointAuthFailedCallback? onAuthFailed;

  SupabasePrivateChannelAuthorizationDelegate({
    required this.authorizationEndpoint,
    required this.supabase,
    required this.httpClient,
    this.onAuthFailed,
  });

  @override
  Future<PrivateChannelAuthorizationData> authorizationData(
    String socketId,
    String channelName,
  ) async {
    var session = supabase.auth.currentSession;
    if (session == null) {
      throw const PatientAppointmentRealtimeAuthorizationException(
        'No hay una sesión autenticada.',
      );
    }

    if (session.isExpired) {
      session = (await supabase.auth.refreshSession()).session;
    }

    if (session == null) {
      throw const PatientAppointmentRealtimeAuthorizationException(
        'No se pudo renovar la sesión.',
      );
    }

    final response = await httpClient.post(
      authorizationEndpoint,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'socket_id': socketId, 'channel_name': channelName},
    );

    if (response.statusCode != 200) {
      throw PatientAppointmentRealtimeAuthorizationException(
        'El backend rechazó la suscripción (${response.statusCode}).',
      );
    }

    final body = jsonDecode(response.body);
    final auth = body is Map<String, dynamic> ? body['auth'] : null;
    if (auth is! String || auth.isEmpty) {
      throw const PatientAppointmentRealtimeAuthorizationException(
        'La respuesta de autorización no contiene una firma válida.',
      );
    }

    return PrivateChannelAuthorizationData(authKey: auth);
  }
}

class PatientAppointmentRealtimeAuthorizationException implements Exception {
  final String message;

  const PatientAppointmentRealtimeAuthorizationException(this.message);

  @override
  String toString() => message;
}

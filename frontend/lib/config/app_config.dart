class AppConfig {
  static const String supabaseUrl = 'https://alnbzufubvxmikusvynx.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_IzRm1fHfe93THS5bPeDUOA_1kuJqs0M';
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    //defaultValue: 'https://medinet.lat/api', // Servidor
    defaultValue: 'http://localhost:8880/api', // Local
  );
  static const String reverbHost = String.fromEnvironment(
    'REVERB_WS_HOST',
    defaultValue: 'medinet.lat',
  );
  static const int reverbPort = int.fromEnvironment(
    'REVERB_WS_PORT',
    defaultValue: 443,
  );
  static const String reverbScheme = String.fromEnvironment(
    'REVERB_WS_SCHEME',
    defaultValue: 'wss',
  );
  static const String reverbAppKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: '4e836df03ccf5c509e2b22c46f29daa58152ce10',
  );

  static Uri get broadcastingAuthUrl => Uri.parse('$apiUrl/broadcasting/auth');
}

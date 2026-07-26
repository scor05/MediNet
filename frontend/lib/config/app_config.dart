class AppConfig {
  static const String supabaseUrl = 'https://alnbzufubvxmikusvynx.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_IzRm1fHfe93THS5bPeDUOA_1kuJqs0M';
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://medinet.lat/api', // Servidor
    //defaultValue: 'http://localhost:8880/api', // Local
  );
}

abstract interface class RealtimeConnection {
  Stream<void> get changes;

  Future<void> connect();

  Future<void> dispose();
}

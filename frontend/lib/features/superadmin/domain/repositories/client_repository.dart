import '../entities/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients();
  Future<Client> toggleClientStatus(int id, bool isActive);
  Future<Client> createClient({
    required String name,
    required String nit,
    int? userId,
  });
  Future<Client> editClient(
    int id, {
    required String name,
    required String nit,
  });
}

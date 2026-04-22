import 'package:frontend/features/client/domain/entities/client.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';

abstract class ClientRepository {
  /*
  ---------------------------------------- Clientes ---------------------------------------
  */

  // Obtiene todos los clientes
  Future<List<Client>> getClients();

  // Cambia el estado de un cliente
  Future<Client> toggleClientStatus(int id, bool isActive);

  // Crea un nuevo cliente
  Future<Client> createClient({
    required String name,
    required String nit,
    int? userId,
  });

  // Edita la información de un cliente
  Future<Client> editClient(
    int id, {
    required String name,
    required String nit,
  });

  /*
  ---------------------------------------- Usuarios de Clientes ---------------------------------------
  */

  // Obtiene los usuarios de un cliente
  Future<List<ClientUser>> getClientUsers(int clientId);

  // Obtiene los usuarios disponibles para agregar a un cliente
  Future<List<ClientUser>> getAvailableUsersForClient(
    int clientId,
    String search,
  );

  // Agrega un usuario a un cliente
  Future<ClientUser> addUserToClient(
    int clientId,
    int userId,
    int role,
    bool isAdmin,
  );

  // Actualiza un usuario de un cliente
  Future<ClientUser> editClientUser(
    int clientId,
    int userId,
    int role,
    bool isAdmin,
    bool isActive,
  );
}

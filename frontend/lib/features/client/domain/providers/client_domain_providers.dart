import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/client/data/providers/client_data_providers.dart';
import 'package:frontend/features/client/domain/usecases/add_user_to_client_usecase.dart';
import 'package:frontend/features/client/domain/usecases/create_client_usecase.dart';
import 'package:frontend/features/client/domain/usecases/edit_client_usecase.dart';
import 'package:frontend/features/client/domain/usecases/edit_client_user_usecase.dart';
import 'package:frontend/features/client/domain/usecases/get_available_users_for_client_usecase.dart';
import 'package:frontend/features/client/domain/usecases/get_client_users_usecase.dart';
import 'package:frontend/features/client/domain/usecases/get_clients_usecase.dart';
import 'package:frontend/features/client/domain/usecases/toggle_client_status_usecase.dart';

/*
---------------------------------------- Clientes ---------------------------------------
*/

// Provider para el usecase getClients
final getClientsUsecaseProvider = Provider((ref) {
  return GetClientsUsecase(ref.read(clientRepositoryProvider));
});

// Provider para el usecase toggleClientStatus
final toggleClientStatusUsecaseProvider = Provider((ref) {
  return ToggleClientStatusUseCase(ref.read(clientRepositoryProvider));
});

// Provider para el usecase editClient
final editClientUsecaseProvider = Provider((ref) {
  return EditClientUsecase(ref.read(clientRepositoryProvider));
});

// Provider para el usecase createClient
final createClientUsecaseProvider = Provider((ref) {
  return CreateClientUsecase(ref.read(clientRepositoryProvider));
});

/*
---------------------------------------- Usuarios de Clientes ---------------------------------------
*/

// Provider para el usecase addUserToClient
final addUserToClientUsecaseProvider = Provider((ref) {
  return AddUserToClientUsecase(ref.read(clientRepositoryProvider));
});

// Provider para el usecase editClientUser
final editClientUserUsecaseProvider = Provider((ref) {
  return EditClientUserUsecase(ref.read(clientRepositoryProvider));
});

// Provider para el usecase getClientUsers
final getClientUsersUsecaseProvider = Provider((ref) {
  return GetClientUsersUsecase(ref.read(clientRepositoryProvider));
});

// Provider para el usecase getAvailableUsersForClient
final getAvailableUsersForClientUsecaseProvider = Provider((ref) {
  return GetAvailableUsersForClientUsecase(ref.read(clientRepositoryProvider));
});

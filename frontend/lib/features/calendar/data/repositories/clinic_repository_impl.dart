import '../../domain/entities/clinic.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../datasources/clinic_remote_datasource.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicRemoteDatasource datasource;

  ClinicRepositoryImpl(this.datasource);

  @override
  Future<List<Clinic>> getClinics() async {
    try {
      return await datasource.getClinics();
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  @override
  Future<void> createClinic({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      await datasource.createClinic(
        name: name,
        address: address,
        phone: phone,
        email: email,
      );
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }
}

import '../repositories/clinic_repository.dart';

class CreateClinic {
  final ClinicRepository repository;

  CreateClinic(this.repository);

  Future<void> call({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    return await repository.createClinic(
      name: name,
      address: address,
      phone: phone,
      email: email,
    );
  }
}

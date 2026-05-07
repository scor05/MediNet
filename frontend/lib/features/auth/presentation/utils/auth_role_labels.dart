class AuthRoleLabels {
  const AuthRoleLabels._();

  static String label(String role) {
    switch (role) {
      case 'doctor':
        return 'Doctor';
      case 'secretary':
        return 'Secretaria';
      case 'admin':
        return 'Administrador';
      case 'patient':
        return 'Paciente';
      default:
        return role;
    }
  }
}

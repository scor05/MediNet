class AuthResult {
  final bool success;
  final String? error;

  const AuthResult({
    required this.success,
    this.error,
  });

  const AuthResult.success()
      : success = true,
        error = null;

  const AuthResult.error(String message)
      : success = false,
        error = message;
}
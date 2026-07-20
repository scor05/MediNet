import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/exceptions/api_exception.dart';

void main() {
  group('ApiException — getters de clasificación de error', () {
    group('isUnauthorized', () {
      test('es true cuando statusCode es 401', () {
        // Arrange
        final exception = ApiException('No autorizado', statusCode: 401);

        // Act & Assert
        expect(exception.isUnauthorized, isTrue);
      });

      test('es false cuando statusCode es 400', () {
        // Arrange
        final exception = ApiException('Bad request', statusCode: 400);

        // Act & Assert
        expect(exception.isUnauthorized, isFalse);
      });

      test('es false cuando statusCode es null', () {
        // Arrange
        final exception = ApiException('Sin código');

        // Act & Assert
        expect(exception.isUnauthorized, isFalse);
      });
    });

    group('isValidation', () {
      test('es true cuando statusCode es 422', () {
        // Arrange
        final exception = ApiException('Error de validación', statusCode: 422);

        // Act & Assert
        expect(exception.isValidation, isTrue);
      });

      test('es false cuando statusCode es 400', () {
        // Arrange
        final exception = ApiException('Bad request', statusCode: 400);

        // Act & Assert
        expect(exception.isValidation, isFalse);
      });

      test('es false cuando statusCode es null', () {
        // Arrange
        final exception = ApiException('Sin código');

        // Act & Assert
        expect(exception.isValidation, isFalse);
      });
    });

    group('isServerError', () {
      test('es true cuando statusCode es 500', () {
        // Arrange
        final exception = ApiException('Internal Server Error', statusCode: 500);

        // Act & Assert
        expect(exception.isServerError, isTrue);
      });

      test('es true cuando statusCode es 503', () {
        // Arrange
        final exception = ApiException('Service Unavailable', statusCode: 503);

        // Act & Assert
        expect(exception.isServerError, isTrue);
      });

      test('es false cuando statusCode es 422 (< 500)', () {
        // Arrange
        final exception = ApiException('Validation', statusCode: 422);

        // Act & Assert
        expect(exception.isServerError, isFalse);
      });

      test('es false cuando statusCode es null', () {
        // Arrange
        final exception = ApiException('Sin código');

        // Act & Assert
        expect(exception.isServerError, isFalse);
      });

      // Boundary: 499 es el valor inmediatamente anterior al umbral 500
      test('es false cuando statusCode es 499 (límite inferior del rango)', () {
        // Arrange
        final exception = ApiException('Otro error', statusCode: 499);

        // Act & Assert
        expect(exception.isServerError, isFalse);
      });
    });

    group('Exclusividad de getters', () {
      test('solo isUnauthorized es true para 401', () {
        // Arrange
        final exception = ApiException('No autorizado', statusCode: 401);

        // Act & Assert
        expect(exception.isUnauthorized, isTrue);
        expect(exception.isValidation, isFalse);
        expect(exception.isServerError, isFalse);
      });

      test('solo isValidation es true para 422', () {
        // Arrange
        final exception = ApiException('Validación', statusCode: 422);

        // Act & Assert
        expect(exception.isUnauthorized, isFalse);
        expect(exception.isValidation, isTrue);
        expect(exception.isServerError, isFalse);
      });

      test('solo isServerError es true para 500', () {
        // Arrange
        final exception = ApiException('Error interno', statusCode: 500);

        // Act & Assert
        expect(exception.isUnauthorized, isFalse);
        expect(exception.isValidation, isFalse);
        expect(exception.isServerError, isTrue);
      });
    });

    group('toString', () {
      test('retorna el mensaje de la excepción', () {
        // Arrange
        final exception = ApiException('Error inesperado', statusCode: 500);

        // Act
        final result = exception.toString();

        // Assert
        expect(result, equals('Error inesperado'));
      });
    });
  });
}

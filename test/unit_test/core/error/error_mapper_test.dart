import 'package:flutter_test/flutter_test.dart';
import 'package:prueba_tecnica_1/core/error/error_mapper.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';

void main() {
  group('mapExceptionToFailure', () {
    test('should return NetworkFailure when exception is NetworkException', () {
      // ARRANGE
      final exception = NetworkException();

      // Act
      final result = mapExceptionToFailure(exception);

      // ASSERT
      expect(result, isA<NetworkFailure>());
    });
    test('should return NetworkFailure when exception is NetworkException', () {
      // ARRANGE
      final exception = ServerException(statusCode: 404);

      // ACT
      final result = mapExceptionToFailure(exception);

      // ASSERT
      expect(result, isA<ServerFailure>());
    });

    test('should return ParsingFailure when exception is ParsingException', () {
      // ARRANGE
      final exception = ParsingException();

      // ACT
      final result = mapExceptionToFailure(exception);

      // ASSERT
      expect(result, isA<ParsingFailure>());
    });

    test('should return CacheFailure when exception is CacheException', () {
      // ARRANGE
      final exception = CacheException();

      // ACT
      final result = mapExceptionToFailure(exception);

      // ASSERT
      expect(result, isA<CacheFailure>());
    });

    test('should return UnknownFailure when exception is UnknownException', () {
      // ARRANGE
      final exception = UnknownException();

      // ACT
      final result = mapExceptionToFailure(exception);

      // ASSERT
      expect(result, isA<UnknownFailure>());
    });
  });
}

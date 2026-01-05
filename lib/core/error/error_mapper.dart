import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'exceptions.dart';

Failure mapExceptionToFailure(Exception exception) {
  if (exception is NetworkException) {
    return const NetworkFailure();
  }

  if (exception is ServerException) {
    return ServerFailure(
      message: exception.message,
      statusCode: exception.statusCode,
    );
  }

  if (exception is ParsingException) {
    return const ParsingFailure();
  }

  if (exception is CacheException) {
    return const CacheFailure();
  }

  if (exception is UnknownException) {
    return const UnknownFailure();
  }

  return const UnknownFailure();
}

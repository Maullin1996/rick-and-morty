import 'package:prueba_tecnica_1/core/utils/constants.dart';

abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Fallo de red
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = ErrorMessages.noInternet]);
}

/// Fallo del servidor
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required String message, required this.statusCode})
    : super(message);
}

/// Fallo de parseo
class ParsingFailure extends Failure {
  const ParsingFailure([super.message = ErrorMessages.parsingError]);
}

/// Fallo de cache
class CacheFailure extends Failure {
  const CacheFailure([super.message = ErrorMessages.cacheError]);
}

/// Fallo desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = ErrorMessages.unknownError]);
}

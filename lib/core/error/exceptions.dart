class AppException implements Exception {
  final String message;

  const AppException(this.message);
}

/// Error de red (sin internet, timeout, DNS, etc.)
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Error HTTP controlado (400, 401, 403, 404, 500, etc.)
class ServerException extends AppException {
  final int statusCode;

  const ServerException({
    String message = 'Server error',
    required this.statusCode,
  }) : super(message);
}

/// Error al convertir JSON / parsear datos
class ParsingException extends AppException {
  const ParsingException([super.message = 'Parsing error']);
}

/// Error de cache o almacenamiento local
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

/// Error desconocido (fallback)
class UnknownException extends AppException {
  const UnknownException([super.message = 'Unknown error']);
}

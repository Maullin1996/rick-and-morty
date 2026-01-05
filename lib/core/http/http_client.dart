import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/utils/constants.dart';

class HttpClient {
  final http.Client _client;

  HttpClient(this._client);

  Future<http.Response> get(Uri uri) async {
    return _retry(() async {
      try {
        final response = await _client
            .get(uri)
            .timeout(const Duration(seconds: 5));
        _validateResponse(response);

        return response;
      } on SocketException {
        throw const NetworkException();
      } on TimeoutException {
        throw const NetworkException('Request timeout');
      }
    });
  }

  void _validateResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) return;

    String message = ErrorMessages.serverError;

    try {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        message = decoded['error'];
      }
    } catch (_) {}

    throw ServerException(statusCode: statusCode, message: message);
  }

  Future<T> _retry<T>(
    Future<T> Function() request, {
    int retries = 1,
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    try {
      return await request();
    } on NetworkException {
      if (retries <= 0) rethrow;
      await Future.delayed(delay);

      return _retry(request, retries: retries - 1, delay: delay);
    }
  }
}

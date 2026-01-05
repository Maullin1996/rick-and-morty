import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/http/http_client.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttp;
  late HttpClient client;

  setUp(() {
    mockHttp = MockHttpClient();
    client = HttpClient(mockHttp);
  });
  group('Http.cliente', () {
    test('should return http.Response when status code is 200', () async {
      // Arrange
      final uri = Uri.parse('https://example.com');

      when(() => mockHttp.get(uri)).thenAnswer(
        (_) async => http.Response(json.encode({'data': 'ok'}), 200),
      );

      // ACT
      final response = await client.get(uri);

      // ASSERT
      expect(response.statusCode, 200);
      expect(response.body, contains('ok'));

      verify(() => mockHttp.get(uri)).called(3);
    });

    test('should return SocketException when status code is 10060', () async {
      // Arrange
      final uri = Uri.parse('https://example.com');

      when(() => mockHttp.get(uri)).thenThrow(const SocketException(''));

      //Act && Assert
      await expectLater(
        () => client.get(uri),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      "should return TimeaoutException when the server didn't response",
      () async {
        // Arrange
        final uri = Uri.parse('https://example.com');

        when(() => mockHttp.get(uri)).thenThrow(TimeoutException(''));

        //Act && Assert
        await expectLater(
          () => client.get(uri),
          throwsA(isA<NetworkException>()),
        );
      },
    );

    test('should return fail when status code is 500', () async {
      // Arrange
      final uri = Uri.parse('https://example.com');

      when(() => mockHttp.get(uri)).thenAnswer(
        (_) async => http.Response(json.encode('{"error":"fail"}'), 500),
      );

      //Assert
      await expectLater(
        () => client.get(uri),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Error del servidor')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test(
      'should retry once and succeed when first call throws SocketException',
      () async {
        // ARRANGE
        final uri = Uri.parse('https://example.com');
        int callCount = 0;

        when(() => mockHttp.get(uri)).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw const SocketException('no connection');
          }
          return http.Response('{"data":"ok"}', 200);
        });

        //Act
        final response = await client.get(uri);

        //Assert
        expect(response.statusCode, 200);
        verify(() => mockHttp.get(uri)).called(2);
      },
    );
  });
}

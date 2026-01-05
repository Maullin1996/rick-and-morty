import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/http/http_client.dart';
import 'package:prueba_tecnica_1/feature/character/data/datasources/character_remote_datasource_impl.dart';
import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';

import '../../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHttpClient client;
  late CharacterRemoteDatasourceImpl datasource;

  setUp(() {
    client = MockHttpClient();
    datasource = CharacterRemoteDatasourceImpl(client);
  });

  const tId = 1;
  final uri = Uri.parse('https://rickandmortyapi.com/api/character/$tId');

  test('should return data when the status code is equal to 200', () async {
    when(
      () => client.get(uri),
    ).thenAnswer((_) async => http.Response(fixture('character.json'), 200));

    //Act
    final result = await datasource.getCharacters(id: tId);

    // Assert
    expect(result, isA<CharacterModel>());
    expect(result.id, 1);
    expect(result.status, 'Alive');
    expect(result.origin.name, 'Earth (C-137)');
    verify(() => client.get(uri)).called(1);
  });

  test('Should return an exception when the status code is equal to 404', () {
    when(
      () => client.get(uri),
    ).thenAnswer((_) async => http.Response('error', 404));

    expect(
      () => datasource.getCharacters(id: tId),
      throwsA(isA<ServerException>()),
    );
    expect(
      () => datasource.getCharacters(id: tId),
      throwsA(
        isA<ServerException>()
            .having((e) => e.message, 'message', 'Error loading characters')
            .having((e) => e.statusCode, 'statusCode', 404),
      ),
    );
  });

  test('Should return an exception when the json is invalid', () {
    when(
      () => client.get(uri),
    ).thenAnswer((_) async => http.Response('INVALID JSON', 200));
    expect(
      () => datasource.getCharacters(id: tId),
      throwsA(isA<ParsingException>()),
    );
  });

  test('Should return an exception when timeout', () {
    when(() => client.get(uri)).thenThrow(TimeoutException('timeout'));
    expect(
      () => datasource.getCharacters(id: tId),
      throwsA(isA<NetworkException>()),
    );
  });
}

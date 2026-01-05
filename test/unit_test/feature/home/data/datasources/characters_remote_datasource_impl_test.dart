import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/http/http_client.dart';
import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';
import 'package:prueba_tecnica_1/feature/home/data/datasources/characters_remote_datasource_impl.dart';

import '../../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHttpClient client;
  late CharactersRemoteDatasourceImpl datasource;

  setUp(() {
    client = MockHttpClient();
    datasource = CharactersRemoteDatasourceImpl(client);
  });

  Uri createUrl({int page = 1, String? status, String? name}) {
    final query = <String, String>{
      'page': '$page',
      if (status != null) 'status': status,
      if (name != null && name.isNotEmpty) 'name': name,
    };

    return Uri.https('rickandmortyapi.com', '/api/character', query);
  }

  test('should return data when the status code is equal to 200', () async {
    when(() => client.get(createUrl())).thenAnswer(
      (_) async => http.Response(fixture('character_list.json'), 200),
    );

    //Act
    final result = await datasource.getCharacters();

    // Assert
    expect(result, isA<List<CharacterModel>>());
    expect(result.length, 2);
    expect(result.first.id, 1);
    expect(result.first.name, 'Rick Sanchez');
  });

  test('should return data when the status is alive', () async {
    when(() => client.get(createUrl(status: 'Alive'))).thenAnswer(
      (_) async => http.Response(fixture('character_list.json'), 200),
    );

    //Act
    final result = await datasource.getCharacters(status: 'Alive');

    // Assert
    expect(result, isA<List<CharacterModel>>());
    expect(result.length, 2);
    expect(result.first.id, 1);
    expect(result.first.name, 'Rick Sanchez');
  });

  test('Should return an exception when the status code is equal to 404', () {
    when(
      () => client.get(createUrl()),
    ).thenAnswer((_) async => http.Response('error', 404));

    expect(() => datasource.getCharacters(), throwsA(isA<ServerException>()));
    expect(
      () => datasource.getCharacters(),
      throwsA(
        isA<ServerException>()
            .having((e) => e.message, 'message', 'Error loading characters')
            .having((e) => e.statusCode, 'statusCode', 404),
      ),
    );
  });

  test('Should return an exception when the json is invalid', () {
    when(
      () => client.get(createUrl()),
    ).thenAnswer((_) async => http.Response('INVALID JSON', 200));

    expect(() => datasource.getCharacters(), throwsA(isA<ParsingException>()));
  });

  test('Should return an exception when timeout', () {
    when(() => client.get(createUrl())).thenThrow(TimeoutException('timeout'));
    expect(() => datasource.getCharacters(), throwsA(isA<NetworkException>()));
  });

  test('Should return UnknownException when unexpected', () {
    when(() => client.get(createUrl())).thenThrow(UnknownException());
    expect(() => datasource.getCharacters(), throwsA(isA<UnknownException>()));
  });
}

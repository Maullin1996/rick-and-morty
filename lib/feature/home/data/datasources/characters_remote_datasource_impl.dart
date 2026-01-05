import 'dart:async';
import 'dart:convert';

import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/http/http_client.dart';
import 'package:prueba_tecnica_1/feature/home/data/datasources/characters_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';

class CharactersRemoteDatasourceImpl implements CharactersRemoteDatasource {
  final HttpClient client;

  CharactersRemoteDatasourceImpl(this.client);
  @override
  Future<List<CharacterModel>> getCharacters({
    int page = 1,
    String? status,
    String? name,
  }) async {
    final query = <String, String>{
      'page': '$page',
      if (status != null) 'status': status,
      if (name != null && name.isEmpty) 'name': name,
    };

    final uri = Uri.https('rickandmortyapi.com', '/api/character', query);
    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw ServerException(
          statusCode: response.statusCode,
          message: 'Error loading characters',
        );
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = decoded['results'] as List;

      return results.map((json) => CharacterModel.fromJson(json)).toList();
    } on ServerException {
      rethrow;
    } on FormatException {
      throw const ParsingException();
    } on TimeoutException {
      throw const NetworkException();
    } catch (_) {
      throw const UnknownException();
    }
  }
}

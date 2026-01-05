import 'dart:async';
import 'dart:convert';

import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/http/http_client.dart';
import 'package:prueba_tecnica_1/feature/character/data/datasources/character_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/character/data/model/character_model.dart';

class CharacterRemoteDatasourceImpl implements CharacterRemoteDatasource {
  final HttpClient client;

  CharacterRemoteDatasourceImpl(this.client);

  @override
  Future<CharacterModel> getCharacters({required int id}) async {
    try {
      final response = await client.get(
        Uri.parse('https://rickandmortyapi.com/api/character/$id'),
      );
      if (response.statusCode != 200) {
        throw ServerException(
          statusCode: response.statusCode,
          message: 'Error loading characters',
        );
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final result = CharacterModel.fromJson(decoded);

      return result;
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

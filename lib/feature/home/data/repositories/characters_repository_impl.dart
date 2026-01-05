import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/data/datasources/characters_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/character/data/helpers/character_adapter.dart';
import 'package:prueba_tecnica_1/feature/home/domain/repository/characters_repository.dart';

class CharactersRepositoryImpl implements CharactersRepository {
  final CharactersRemoteDatasource remote;

  const CharactersRepositoryImpl(this.remote);
  @override
  Future<Either<Failure, List<Character>>> getCharacters({
    int page = 1,
    String? status,
    String? name,
  }) async {
    try {
      final models = await remote.getCharacters(page: page, status: status);
      final characters = models
          .map((e) => characterModelToCharacter(e))
          .toList();

      return Right(characters);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('Unexpected error'));
    }
  }
}

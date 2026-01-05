import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/data/datasources/character_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/character/data/helpers/character_adapter.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/character/domain/repositories/character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterRemoteDatasource remote;

  const CharacterRepositoryImpl(this.remote);
  @override
  Future<Either<Failure, Character>> getCharacter({required int id}) async {
    try {
      final model = await remote.getCharacters(id: id);
      final character = characterModelToCharacter(model);

      return Right(character);
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

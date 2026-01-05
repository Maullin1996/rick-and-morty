import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

abstract class CharacterRepository {
  Future<Either<Failure, Character>> getCharacter({required int id});
}

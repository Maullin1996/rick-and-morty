import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

abstract class CharactersRepository {
  Future<Either<Failure, List<Character>>> getCharacters({
    int page = 1,
    String? name,
    String? status,
  });
}

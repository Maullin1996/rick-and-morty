import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/character/domain/repositories/character_repository.dart';

class CharacterUseCase {
  final CharacterRepository repo;

  const CharacterUseCase(this.repo);

  Future<Either<Failure, Character>> call({required int id}) {
    return repo.getCharacter(id: id);
  }
}

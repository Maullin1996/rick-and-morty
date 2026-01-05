import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/home/domain/repository/characters_repository.dart';

class CharactersUseCase {
  final CharactersRepository repo;

  const CharactersUseCase(this.repo);

  Future<Either<Failure, List<Character>>> call({
    int page = 1,
    String? status,
    String? name,
  }) {
    return repo.getCharacters(page: page, name: name, status: status);
  }
}

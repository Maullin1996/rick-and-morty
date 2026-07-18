import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/domain/repositories/favorite_repository.dart';

class FavoriteUseCase {
  final FavoriteRepository repo;

  const FavoriteUseCase(this.repo);

  Future<Either<Failure, List<Character>>> getFavorites() {
    return repo.getFavorites();
  }

  Future<Either<Failure, Unit>> addFavorite(Character character) {
    return repo.addFavorite(character);
  }

  Future<Either<Failure, Unit>> removeFavorite(int id) {
    return repo.removeFavorite(id);
  }
}

import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, List<Character>>> getFavorites();

  Future<Either<Failure, Unit>> addFavorite(Character character);

  Future<Either<Failure, Unit>> removeFavorite(int id);
}

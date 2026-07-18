import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/usecase/auth_use_case.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/favorite/domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDatasource remote;
  final AuthUseCase authUseCase;

  const FavoriteRepositoryImpl(this.remote, this.authUseCase);

  Future<Either<Failure, T>> _withUser<T>(
    Future<T> Function(String uid) action,
  ) async {
    final uid = authUseCase.currentUserId;
    if (uid == null) {
      return const Left(AuthFailure('Debes iniciar sesión'));
    }

    try {
      return Right(await action(uid));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getFavorites() {
    return _withUser((uid) => remote.getFavorites(uid));
  }

  @override
  Future<Either<Failure, Unit>> addFavorite(Character character) {
    return _withUser((uid) async {
      await remote.addFavorite(uid, character);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(int id) {
    return _withUser((uid) async {
      await remote.removeFavorite(uid, id);
      return unit;
    });
  }
}

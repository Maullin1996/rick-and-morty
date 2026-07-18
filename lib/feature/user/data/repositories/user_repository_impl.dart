import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/usecase/auth_use_case.dart';
import 'package:prueba_tecnica_1/feature/user/data/datasources/user_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';
import 'package:prueba_tecnica_1/feature/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remote;
  final AuthUseCase authUseCase;

  const UserRepositoryImpl(this.remote, this.authUseCase);

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
  Future<Either<Failure, UserProfile?>> getProfile() {
    return _withUser((uid) => remote.getProfile(uid));
  }

  @override
  Future<Either<Failure, Unit>> saveProfile(UserProfile profile) {
    return _withUser((uid) async {
      await remote.saveProfile(uid, profile);
      return unit;
    });
  }
}

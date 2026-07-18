import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;

  const AuthRepositoryImpl(this.remote);

  @override
  bool get isLoggedIn => remote.isLoggedIn;

  @override
  String? get currentUserId => remote.currentUserId;

  @override
  Stream<bool> get authStateChanges => remote.authStateChanges;

  @override
  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await remote.signInWithEmailAndPassword(email: email, password: password);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> register({
    required String email,
    required String password,
  }) async {
    try {
      await remote.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    try {
      await remote.signInWithGoogle();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<void> signOut() => remote.signOut();
}

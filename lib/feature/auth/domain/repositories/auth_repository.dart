import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';

abstract class AuthRepository {
  bool get isLoggedIn;

  String? get currentUserId;

  Stream<bool> get authStateChanges;

  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> register({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signInWithGoogle();

  Future<void> signOut();
}

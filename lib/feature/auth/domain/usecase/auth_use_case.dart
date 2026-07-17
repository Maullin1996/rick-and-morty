import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository repo;

  const AuthUseCase(this.repo);

  bool get isLoggedIn => repo.isLoggedIn;

  Stream<bool> get authStateChanges => repo.authStateChanges;

  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) {
    return repo.signIn(email: email, password: password);
  }

  Future<Either<Failure, Unit>> register({
    required String email,
    required String password,
  }) {
    return repo.register(email: email, password: password);
  }

  Future<Either<Failure, Unit>> signInWithGoogle() {
    return repo.signInWithGoogle();
  }

  Future<void> signOut() {
    return repo.signOut();
  }
}

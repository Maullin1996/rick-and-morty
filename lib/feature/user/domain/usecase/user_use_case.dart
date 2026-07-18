import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';
import 'package:prueba_tecnica_1/feature/user/domain/repositories/user_repository.dart';

class UserUseCase {
  final UserRepository repo;

  const UserUseCase(this.repo);

  Future<Either<Failure, UserProfile?>> getProfile() {
    return repo.getProfile();
  }

  Future<Either<Failure, Unit>> saveProfile(UserProfile profile) {
    return repo.saveProfile(profile);
  }
}

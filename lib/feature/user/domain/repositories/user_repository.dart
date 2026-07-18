import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile?>> getProfile();

  Future<Either<Failure, Unit>> saveProfile(UserProfile profile);
}

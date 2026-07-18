import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';

abstract class UserRemoteDatasource {
  Future<UserProfile?> getProfile(String uid);

  Future<void> saveProfile(String uid, UserProfile profile);
}

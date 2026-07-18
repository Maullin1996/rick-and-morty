import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/feature/user/data/datasources/user_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final FirebaseFirestore _firestore;

  UserRemoteDatasourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _profileRef(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Future<UserProfile?> getProfile(String uid) async {
    try {
      final snapshot = await _profileRef(uid).get();
      final data = snapshot.data();
      if (data == null) return null;

      return UserProfile.fromJson(data);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error', statusCode: 0);
    } on FormatException {
      throw const ParsingException();
    } catch (_) {
      throw const UnknownException();
    }
  }

  @override
  Future<void> saveProfile(String uid, UserProfile profile) async {
    try {
      await _profileRef(uid).set(profile.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error', statusCode: 0);
    } catch (_) {
      throw const UnknownException();
    }
  }
}

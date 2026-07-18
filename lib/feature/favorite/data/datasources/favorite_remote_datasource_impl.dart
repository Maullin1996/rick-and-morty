import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/feature/character/domain/entities/character.dart';
import 'package:prueba_tecnica_1/feature/favorite/data/datasources/favorite_remote_datasource.dart';

class FavoriteRemoteDatasourceImpl implements FavoriteRemoteDatasource {
  final FirebaseFirestore _firestore;

  FavoriteRemoteDatasourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _favoritesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  @override
  Future<List<Character>> getFavorites(String uid) async {
    try {
      final snapshot = await _favoritesRef(
        uid,
      ).orderBy('addedAt', descending: true).get();

      return snapshot.docs
          .map((doc) => Character.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error', statusCode: 0);
    } on FormatException {
      throw const ParsingException();
    } catch (_) {
      throw const UnknownException();
    }
  }

  @override
  Future<void> addFavorite(String uid, Character character) async {
    try {
      await _favoritesRef(uid).doc(character.id.toString()).set({
        ...character.toJson(),
        'addedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error', statusCode: 0);
    } catch (_) {
      throw const UnknownException();
    }
  }

  @override
  Future<void> removeFavorite(String uid, int characterId) async {
    try {
      await _favoritesRef(uid).doc(characterId.toString()).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error', statusCode: 0);
    } catch (_) {
      throw const UnknownException();
    }
  }
}

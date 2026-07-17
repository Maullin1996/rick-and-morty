import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/core/utils/constants.dart';
import 'package:prueba_tecnica_1/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/auth/data/helpers/auth_error_mapper.dart';
import 'package:prueba_tecnica_1/firebase_options.dart';

// Web client (client_type 3) from android/app/google-services.json, used so
// GoogleSignIn.authenticate() returns an idToken Firebase can accept.
const _googleWebClientId =
    '870161096208-tetg22v787ovmoickjkam02a340p87kq.apps.googleusercontent.com';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  @override
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  @override
  Stream<bool> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((user) => user != null);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCode(e.code));
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCode(e.code));
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      if (!_googleInitialized) {
        await _googleSignIn.initialize(
          clientId: !kIsWeb && Platform.isIOS
              ? DefaultFirebaseOptions.ios.iosClientId
              : null,
          serverClientId: _googleWebClientId,
        );
        _googleInitialized = true;
      }

      final account = await _googleSignIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      throw const AuthException(AuthErrorMessages.googleSignInFailed);
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCode(e.code));
    } catch (_) {
      throw const AuthException(AuthErrorMessages.googleSignInFailed);
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}

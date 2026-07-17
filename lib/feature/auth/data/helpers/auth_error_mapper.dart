import 'package:prueba_tecnica_1/core/utils/constants.dart';

String mapFirebaseAuthErrorCode(String code) {
  switch (code) {
    case 'invalid-email':
      return AuthErrorMessages.invalidEmail;
    case 'user-disabled':
      return AuthErrorMessages.userDisabled;
    case 'user-not-found':
      return AuthErrorMessages.userNotFound;
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return AuthErrorMessages.invalidCredential;
    case 'email-already-in-use':
      return AuthErrorMessages.emailAlreadyInUse;
    case 'weak-password':
      return AuthErrorMessages.weakPassword;
    case 'too-many-requests':
      return AuthErrorMessages.tooManyRequests;
    case 'network-request-failed':
      return ErrorMessages.noInternet;
    default:
      return AuthErrorMessages.authUnknown;
  }
}

abstract class AuthRemoteDatasource {
  bool get isLoggedIn;

  String? get currentUserId;

  String? get currentUserEmail;

  Stream<bool> get authStateChanges;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();
}

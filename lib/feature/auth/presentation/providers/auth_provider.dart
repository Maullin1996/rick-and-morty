import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/error/exceptions.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_providers.dart';

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    final useCase = ref.read(authUseCaseProvider);

    final subscription = useCase.authStateChanges.listen(
      (loggedIn) => state = loggedIn,
    );
    ref.onDispose(() {
      subscription.cancel();
    });

    return useCase.isLoggedIn;
  }

  Future<void> signIn({required String email, required String password}) async {
    final result = await ref
        .read(authUseCaseProvider)
        .signIn(email: email, password: password);

    result.fold((failure) => throw AuthException(failure.message), (_) {
      state = true;
    });
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final result = await ref
        .read(authUseCaseProvider)
        .register(email: email, password: password);

    result.fold((failure) => throw AuthException(failure.message), (_) {
      state = true;
    });
  }

  Future<void> signInWithGoogle() async {
    final result = await ref.read(authUseCaseProvider).signInWithGoogle();

    result.fold((failure) => throw AuthException(failure.message), (_) {
      state = true;
    });
  }

  Future<void> signOut() async {
    await ref.read(authUseCaseProvider).signOut();
    state = false;
  }
}

final isLoggedInProvider = NotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

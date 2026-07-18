import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/user/domain/entities/user_profile.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/providers/user_providers.dart';

class UserNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) return null;

    _loadProfile();

    return null;
  }

  Future<void> _loadProfile() async {
    final result = await ref.read(userUseCaseProvider).getProfile();

    result.fold((_) {}, (profile) => state = profile);
  }

  Future<bool> saveProfile(UserProfile profile) async {
    final result = await ref.read(userUseCaseProvider).saveProfile(profile);

    return result.fold((_) => false, (_) {
      state = profile;
      return true;
    });
  }
}

final userProfileProvider = NotifierProvider<UserNotifier, UserProfile?>(
  UserNotifier.new,
);

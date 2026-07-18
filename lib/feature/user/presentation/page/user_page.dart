import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/widgets/description_widget.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/providers/favorite_provider.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/providers/user_provider.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/widgets/edit_profile_form.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final colors = AppColors.of(context);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(profile?.name ?? "Usuario"),
        actions: [
          IconButton(
            key: const Key('edit_profile_button'),
            icon: Icon(Icons.edit_outlined, color: colors.primary),
            onPressed: () => AppBottomSheet.show(
              context,
              title: 'Editar perfil',
              content: EditProfileForm(initialProfile: profile),
            ),
          ),
        ],
      ),
      body: isLoggedIn
          ? const _UserProfileView()
          : AppStateWidget(
              type: AppStateType.empty,
              icon: Icons.person_outline,
              title: 'No has iniciado sesión',
              buttonChild: const Text('Iniciar sesión'),
              onPressed: () => context.push('/login'),
            ),
    );
  }
}

class _UserProfileView extends ConsumerWidget {
  const _UserProfileView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final email = ref.read(authUseCaseProvider).currentUserEmail;
    final favoritesCount = ref.watch(favoriteProvider).length;
    final tokens = AppTokens.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              
            ],
          ),
          AppAssetsImage(
            path: "assets/images/user_image.png",
            errorWidget: Icon(Icons.broken_image_outlined),
          ),
          SizedBox(height: tokens.spacing.medium),
          AppCard(
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.mediumLarge),
              child: Column(
                children: [
                  DescriptionWidget(
                    icon: Icons.cake_outlined,
                    firstText: 'Edad:',
                    secondText: profile != null
                        ? '${profile.age} años'
                        : 'No especificado',
                  ),
                  SizedBox(height: tokens.spacing.small),
                  DescriptionWidget(
                    icon: Icons.public_outlined,
                    firstText: 'País:',
                    secondText: profile?.country ?? 'No especificado',
                  ),
                  SizedBox(height: tokens.spacing.small),
                  DescriptionWidget(
                    icon: Icons.email_outlined,
                    firstText: 'Correo:',
                    secondText: email ?? 'No especificado',
                  ),
                  SizedBox(height: tokens.spacing.small),
                  DescriptionWidget(
                    icon: Icons.favorite_outline,
                    firstText: 'Favoritos:',
                    secondText: '$favoritesCount',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

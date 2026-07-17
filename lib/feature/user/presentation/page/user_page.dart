import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Usuario')),
      body: Center(
        child: isLoggedIn
            ? AppText.h5(
                'Próximamente',
                color: AppColors.of(context).textSecondary,
              )
            : AppStateWidget(
                type: AppStateType.empty,
                icon: Icons.person_outline,
                title: 'No has iniciado sesión',
                buttonChild: const Text('Iniciar sesión'),
                onPressed: () => context.push('/login'),
              ),
      ),
    );
  }
}

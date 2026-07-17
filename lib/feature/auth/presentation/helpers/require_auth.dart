import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';

bool requireAuth(BuildContext context, WidgetRef ref) {
  if (ref.read(isLoggedInProvider)) return true;

  AppSnackBar.show(
    context,
    type: SnackBarType.info,
    message: 'Debes iniciar sesión para guardar favoritos',
    actionLabel: 'Iniciar sesión',
    onAction: () => context.push('/login'),
  );

  return false;
}

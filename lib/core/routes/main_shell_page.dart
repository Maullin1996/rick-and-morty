import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';

class MainShellPage extends ConsumerWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          BottomNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          BottomNavItem(
            icon: Icons.favorite_border,
            selectedIcon: Icons.favorite,
            label: 'Favoritos',
          ),
          if (isLoggedIn)
            BottomNavItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Usuario',
            ),
        ],
      ),
    );
  }
}

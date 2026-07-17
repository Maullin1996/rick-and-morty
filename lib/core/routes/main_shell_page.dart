import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
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

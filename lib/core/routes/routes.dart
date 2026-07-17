import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_tecnica_1/core/routes/main_shell_page.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/page/login_page.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/page/register_page.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/page/character_page.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/page/favorite_page.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/page/home_page.dart';
import 'package:prueba_tecnica_1/feature/user/presentation/page/user_page.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return MainShellPage(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const HomePage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/favorite',
              builder: (BuildContext context, GoRouterState state) {
                return const FavoritePage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/user',
              builder: (BuildContext context, GoRouterState state) {
                return const UserPage();
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/character',
      builder: (BuildContext context, GoRouterState state) {
        final int id = state.extra as int;

        return CharacterPage(id: id);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
      },
    ),
  ],
);

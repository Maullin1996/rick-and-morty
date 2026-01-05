import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_tecnica_1/feature/character/presentation/page/character_page.dart';
import 'package:prueba_tecnica_1/feature/favorite/presentation/page/favorite_page.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/page/home_page.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'favorite',
          builder: (BuildContext context, GoRouterState state) {
            return const FavoritePage();
          },
        ),
        GoRoute(
          path: 'character',
          builder: (BuildContext context, GoRouterState state) {
            final int id = state.extra as int;

            return CharacterPage(id: id);
          },
        ),
      ],
    ),
  ],
);

import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:prueba_tecnica_1/core/routes/routes.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppThemeProvider(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        themeMode: ThemeMode.dark,
        routerConfig: router,
      ),
    );
  }
}

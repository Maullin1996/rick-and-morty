import 'package:atomic_design/design_system.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/firebase_options.dart';
import 'package:prueba_tecnica_1/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AtomicDesignConfig.initializeFromAsset(
    'assets/config/app_config.json',
  );

  runApp(const ProviderScope(child: MainApp()));
}

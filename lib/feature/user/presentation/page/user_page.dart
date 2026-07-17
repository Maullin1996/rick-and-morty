import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuario')),
      body: Center(
        child: AppText.h5(
          'Próximamente',
          color: AppColors.of(context).textSecondary,
        ),
      ),
    );
  }
}

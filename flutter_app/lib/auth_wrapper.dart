// lib/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Mientras carga y aún no hay token, muestra indicador
    if (authState.loading && authState.token == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si hay token, mostramos Home
    if (authState.token != null) {
      return const HomeScreen();
    }

    // En otro caso, mostramos Login
    return const LoginScreen();
  }
}

// lib/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

/// Este widget “envoltorio” se encarga de leer el estado de authProvider
/// y decidir a qué pantalla enviar: LoginScreen (si no hay token) o HomeScreen (si hay token).
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Si el state está cargando, podemos mostrar un indicador
    if (authState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si no hay token almacenado, vamos a LoginScreen
    if (authState.token == null) {
      // Importante: forzar a LoginScreen sin posibilidad de retroceder
      return const LoginScreen();
    }

    // Si hay token, mostramos HomeScreen
    return const HomeScreen();
  }
}

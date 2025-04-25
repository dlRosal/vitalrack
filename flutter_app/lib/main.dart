import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ProviderScope(child: VitalrackApp()));
}

class VitalrackApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Aquí más adelante escucharemos authProvider para redirigir a Login o Home
    return MaterialApp(
      title: 'Vitalrack',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(),
        '/home': (_) => HomeScreen(),
        // Añadiremos rutas de nutrición y entrenamiento más adelante
      },
    );
  }
}

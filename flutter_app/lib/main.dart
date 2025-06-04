// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/training_screen.dart';
import 'screens/routine_detail_screen.dart';
import 'models/routine.dart';

void main() {
  runApp(const ProviderScope(child: VitalrackApp()));
}

class VitalrackApp extends ConsumerWidget {
  const VitalrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'VitalRack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // Ajusta tu tema según tus necesidades
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // El widget que decide “login” vs “home”
      home: const AuthWrapper(),

      // Rutas de toda la app (usar pushNamed)
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/nutrition': (_) => const NutritionScreen(),
        '/training': (_) => const TrainingScreen(),
      },
      // Ruta dinámica para detalles de rutina
      onGenerateRoute: (settings) {
        if (settings.name == '/training/detail') {
          final args = settings.arguments as Routine;
          return MaterialPageRoute(
            builder: (ctx) => RoutineDetailScreen(routine: args),
          );
        }
        return null;
      },
    );
  }
}

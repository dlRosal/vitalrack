import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_wrapper.dart';
import 'models/routine.dart';
import 'screens/nutrition_screen.dart';
import 'screens/training_screen.dart';
import 'screens/routine_detail_screen.dart';


void main() {
  runApp(const ProviderScope(child: VitalrackApp()));
}

class VitalrackApp extends ConsumerWidget {
  const VitalrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'VitalRack',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
      routes: {
        // Rutas protegidas tras login
        '/nutrition': (_) => const NutritionScreen(),
        '/training': (_) => const TrainingScreen(),
        '/training/detail': (ctx) {
          final routine = ModalRoute.of(ctx)!.settings.arguments as Routine;
          return RoutineDetailScreen(routine: routine);
        },
      },
    );
  }
}

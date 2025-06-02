import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineDetailScreen extends StatelessWidget {
  const RoutineDetailScreen({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro
      appBar: AppBar(
        title: Text(routine.name),
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: routine.exercises.isEmpty
            ? const Center(
                child: Text(
                  'Esta rutina no tiene ejercicios.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : ListView.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: routine.exercises.length,
                itemBuilder: (context, index) {
                  final ex = routine.exercises[index];
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        ex.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Sets: ${ex.sets}  Reps: ${ex.reps}\nDescanso: ${ex.restSec}s',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

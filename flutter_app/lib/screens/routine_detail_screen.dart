import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineDetailScreen extends StatelessWidget {
  const RoutineDetailScreen({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0C0F1A);
    final cardColor = const Color(0xFF1B2233);
    final accent = const Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          routine.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    color: cardColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: accent,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        ex.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Sets: ${ex.sets}  Reps: ${ex.reps}\nDescanso: ${ex.restSec}s',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

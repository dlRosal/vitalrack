import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineDetailScreen extends StatelessWidget {
  const RoutineDetailScreen({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: routine.exercises.isEmpty
            ? const Center(child: Text('Esta rutina no tiene ejercicios.'))
            : ListView.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: routine.exercises.length,
                itemBuilder: (context, index) {
                  final ex = routine.exercises[index];
                  return Card(
                    child: ListTile(
                      title: Text(ex.name),
                      subtitle: Text(
                        'Sets: ${ex.sets}  Reps: ${ex.reps}\nDescanso: ${ex.restSec}s',
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/session.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final cardColor = const Color(0xFF101521);
    final accent = const Color(0xFF1E88E5);
    final dateStr = session.date.toLocal().toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: Text('Sesión $dateStr'),
        backgroundColor: const Color(0xFF0A1123),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Duración: ${session.duration} min',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            if (session.notes != null && session.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Notas: ${session.notes}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            const SizedBox(height: 20),
            ...session.entries.map((e) => Card(
                  color: cardColor,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.fitness_center, color: accent),
                    title: Text(
                      e.exerciseName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${e.sets}×${e.reps} - ${e.weight} kg',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
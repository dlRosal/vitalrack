import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineDetailScreen extends StatelessWidget {
  const RoutineDetailScreen({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0A0A0F); // Fondo aún más oscuro
    final cardColor = const Color(0xFF1A1C2D); // Panel de tarjetas
    final accent = const Color(0xFF00FFAA); // Verde neón
    final accentSecondary = const Color(0xFF7F00FF); // Morado
    final glow = accent.withOpacity(0.3); // Efecto neón
    final appBarColor = const Color(0xFF111322); // AppBar oscura

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          routine.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        elevation: 10,
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
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemCount: routine.exercises.length,
                itemBuilder: (context, index) {
                  final ex = routine.exercises[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: glow, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: glow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentSecondary, width: 2),
                          gradient: LinearGradient(
                            colors: [accent, accentSecondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        ex.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          'Series: ${ex.sets}  Repeticiones: ${ex.reps}\nDescanso: ${ex.restSec}s',
                          style: TextStyle(
                            color: Colors.white70.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

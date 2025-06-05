import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineDetailScreen extends StatelessWidget {
  const RoutineDetailScreen({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF080C14); // Azul oscuro profundo
    final cardColor = const Color(0xFF101A2B); // Azul grisáceo oscuro
    final accent = const Color.fromARGB(255, 40, 80, 94); // Azul neón
    final accentSecondary = const Color(0xFF001F3F); // Azul navy
    final glow = accent.withOpacity(0.25); // Efecto neón sutil
    final appBarColor = const Color(0xFF0D1220); // AppBar oscuro azulado

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
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + index * 100),
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: glow, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: glow,
                            blurRadius: 10,
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
                            border:
                                Border.all(color: accentSecondary, width: 2),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}

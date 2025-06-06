import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({super.key, required this.routine});

  final Routine routine;

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF080C14);
    final cardColor = const Color(0xFF101A2B);
    final accent = const Color.fromARGB(255, 40, 80, 94);
    final accentSecondary = const Color(0xFF001F3F);
    final glow = accent.withOpacity(0.25);
    final appBarColor = const Color(0xFF0D1220);

    final routine = widget.routine;

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
            : ListView.builder(
                itemCount: routine.exercises.length,
                itemBuilder: (context, index) {
                  final ex = routine.exercises[index];
                  final delay = (index + 1) * 0.1;
                  final curved = CurvedAnimation(
                    parent: _controller,
                    curve: Interval(delay.clamp(0.0, 1.0), 1.0, curve: Curves.easeOut),
                  );

                  return AnimatedBuilder(
                    animation: curved,
                    builder: (context, child) {
                      final offsetY = 20 * (1 - curved.value);
                      return Opacity(
                        opacity: curved.value,
                        child: Transform.translate(
                          offset: Offset(0, offsetY),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/session.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.session});
  final Session session;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(widget.session.entries.length, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + index * 100),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
    }).toList();

    for (var controller in _controllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final accent = const Color(0xFF1E88E5);
    final neonGreen = const Color(0xFF00FFC6);
    final dateStr = session.date.toLocal().toString().split(' ')[0];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sesión $dateStr',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1E), Color(0xFF060812)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16), // Menos espacio arriba
          child: ListView(
            children: [
              Text(
                '⏱️ Duración: ${session.duration} min',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (session.notes != null && session.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '📝 Notas: ${session.notes}',
                    style: const TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 25),
              ...session.entries.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;

                return SlideTransition(
                  position: _animations[index],
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutExpo,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      leading: Icon(
                        Icons.fitness_center,
                        color: neonGreen,
                        size: 30,
                        shadows: [
                          Shadow(
                            color: neonGreen.withOpacity(0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      title: Text(
                        e.exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        '${e.sets}×${e.reps} - ${e.weight} kg',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

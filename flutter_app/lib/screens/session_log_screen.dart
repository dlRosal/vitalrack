import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../providers/training_provider.dart';

class SessionLogScreen extends ConsumerStatefulWidget {
  const SessionLogScreen({super.key, required this.routine});

  final Routine routine;

  @override
  ConsumerState<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends ConsumerState<SessionLogScreen>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _weightControllers;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  final Color _mainColor = const Color(0xFF0A2A4A); // Azul principal
  final Color _backgroundColor = const Color(0xFF0C0F1A); // Fondo general

  @override
  void initState() {
    super.initState();
    _weightControllers =
        widget.routine.exercises.map((_) => TextEditingController()).toList();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    for (final c in _weightControllers) {
      c.dispose();
    }
    _durationController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveSession() async {
    final duration = int.tryParse(_durationController.text.trim());
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duración válida es obligatoria')),
      );
      return;
    }

    final entries = <Map<String, dynamic>>[];
    for (var i = 0; i < widget.routine.exercises.length; i++) {
      final ex = widget.routine.exercises[i];
      final weight = double.tryParse(_weightControllers[i].text.trim());
      if (weight == null || weight < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Peso válido para "${ex.name}"')),
        );
        return;
      }
      entries.add({
        'exerciseName': ex.name,
        'sets': ex.sets,
        'reps': ex.reps,
        'weight': weight,
      });
    }

    await ref.read(trainingProvider.notifier).logSession(
          widget.routine.id,
          duration,
          entries,
          notes: _notesController.text.trim(),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión registrada')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _mainColor,
        elevation: 0,
        toolbarHeight: 100,
        title: Text(
          'Sesión: ${widget.routine.name}',
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.cyanAccent,
                blurRadius: 12,
              ),
              Shadow(
                color: Colors.blueAccent,
                blurRadius: 24,
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            children: [
              _buildInputField(
                controller: _durationController,
                label: 'Duración (minutos)',
                keyboardType: TextInputType.number,
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 16),
              ...List.generate(widget.routine.exercises.length, (i) {
                final ex = widget.routine.exercises[i];
                return _buildInputField(
                  controller: _weightControllers[i],
                  label: '${ex.name} (${ex.sets}×${ex.reps}) - Peso (kg)',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  icon: Icons.fitness_center,
                );
              }),
              _buildInputField(
                controller: _notesController,
                label: 'Notas (opcional)',
                maxLines: 2,
                icon: Icons.notes,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.loading ? null : _saveSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 12,
                  shadowColor: Colors.cyanAccent.withOpacity(0.5),
                ),
                child: state.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Registrar Sesión',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _mainColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.cyanAccent) : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

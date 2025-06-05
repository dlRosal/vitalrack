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

class _SessionLogScreenState extends ConsumerState<SessionLogScreen> {
  late final List<TextEditingController> _weightControllers;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weightControllers =
        widget.routine.exercises.map((_) => TextEditingController()).toList();
  }

  @override
  void dispose() {
    for (final c in _weightControllers) {
      c.dispose();
    }
    _durationController.dispose();
    _notesController.dispose();
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

    final bgColor = const Color(0xFF0C0F1A);
    final neonAccent = const Color(0xFF00FFC6);
    final titleColor = const Color(0xFF80D8FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: Text(
          'Log Sesión: ${widget.routine.name}',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
        elevation: 4,
        shadowColor: neonAccent.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                backgroundColor: neonAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
                shadowColor: neonAccent.withOpacity(0.7),
              ),
              child: state.loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Registrar Sesión',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
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
        color: const Color(0xFF1B2233),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.white70)
              : null,
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

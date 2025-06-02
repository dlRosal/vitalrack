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
    _weightControllers = widget.routine.exercises
        .map((_) => TextEditingController())
        .toList();
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

  InputDecoration _darkInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.greenAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Log Sesión: ${widget.routine.name}'),
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _darkInputDecoration('Duración (minutos)'),
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.routine.exercises.length, (i) {
              final ex = widget.routine.exercises[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _weightControllers[i],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: _darkInputDecoration(
                    '${ex.name} (${ex.sets}×${ex.reps}) Peso (kg)',
                  ),
                ),
              );
            }),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: _darkInputDecoration('Notas (opcional)'),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: state.loading ? null : _saveSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[700],
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 8,
                shadowColor: Colors.greenAccent.withOpacity(0.4),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

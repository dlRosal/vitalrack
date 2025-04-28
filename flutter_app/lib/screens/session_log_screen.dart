// lib/screens/session_log_screen.dart
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
      final weight = double.tryParse(
        _weightControllers[i].text.trim(),
      );
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

    await ref
        .read(trainingProvider.notifier)
        .logSession(widget.routine.id, duration, entries,
            notes: _notesController.text.trim());

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
      appBar: AppBar(title: Text('Log Sesión: ${widget.routine.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duración (minutos)',
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(widget.routine.exercises.length, (i) {
              final ex = widget.routine.exercises[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _weightControllers[i],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '${ex.name} (${ex.sets}×${ex.reps}) Peso (kg)',
                  ),
                ),
              );
            }),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notas (opcional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.loading ? null : _saveSession,
              child: state.loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Registrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

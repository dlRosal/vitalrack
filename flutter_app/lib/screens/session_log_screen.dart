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
  late final Animation<Offset> _slideAnimation;

  final Color _mainColor = const Color(0xFF0A2A4A);
  final Color _backgroundColor = const Color(0xFF0C0F1A);

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

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
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Sesión: ${widget.routine.name}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
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
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlueAccent.withOpacity(0.6),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: state.loading ? null : _saveSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 16,
                          ),
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
        color: _mainColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _mainColor.withOpacity(0.25),
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
          prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
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

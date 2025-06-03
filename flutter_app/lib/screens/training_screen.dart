import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/training_provider.dart';
import '../models/routine.dart';
import '../models/session.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  String _level = 'beginner';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(trainingProvider.notifier).fetchRoutines();
      ref.read(trainingProvider.notifier).fetchSessions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await ref.read(trainingProvider.notifier).generateRoutine(name, _level);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainingProvider);

    final bgColor = const Color(0xFF0C0F1A);
    final cardColor = const Color(0xFF1B2233);
    final accent = const Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Entrenamiento'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent,
          labelColor: accent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Rutinas'),
            Tab(text: 'Sesiones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Rutinas Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputField(
                  controller: _nameController,
                  label: 'Nombre de la rutina',
                ),
                const SizedBox(height: 12),
                _buildDropdown(),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: state.loading ? null : _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                          'Generar Rutina',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.routines.isEmpty
                      ? const Center(
                          child: Text(
                            'Sin rutinas creadas',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.routines.length,
                          itemBuilder: (context, index) {
                            final Routine r = state.routines[index];
                            return Card(
                              color: cardColor,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  r.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Ejercicios: ${r.exercises.length}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/training/detail',
                                    arguments: r,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Sesiones Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: state.sessions.isEmpty && !state.loading
                ? const Center(
                    child: Text(
                      'Sin sesiones registradas',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : state.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: state.sessions.length,
                        itemBuilder: (context, index) {
                          final Session s = state.sessions[index];
                          final dateStr = s.date.toLocal().toString().split(' ')[0];
                          return Card(
                            color: cardColor,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                'Fecha: $dateStr',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Duración: ${s.duration} min\nNotas: ${s.notes ?? '-'}',
                                style: const TextStyle(color: Colors.white60),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2233),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2233),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        dropdownColor: const Color(0xFF1B2233),
        isExpanded: true,
        value: _level,
        iconEnabledColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'beginner', child: Text('Principiante')),
          DropdownMenuItem(value: 'intermediate', child: Text('Intermedio')),
          DropdownMenuItem(value: 'advanced', child: Text('Avanzado')),
        ],
        onChanged: (v) {
          if (v != null) setState(() => _level = v);
        },
      ),
    );
  }
}

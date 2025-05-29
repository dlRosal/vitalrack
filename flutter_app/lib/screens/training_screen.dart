// lib/screens/training_screen.dart
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenamiento'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Rutinas'), Tab(text: 'Sesiones')],
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
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la rutina',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: _level,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _level = v);
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: state.loading ? null : _generate,
                  child: state.loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Generar Rutina'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.routines.isEmpty
                      ? const Center(child: Text('Sin rutinas creadas'))
                      : ListView.builder(
                          itemCount: state.routines.length,
                          itemBuilder: (context, index) {
                            final Routine r = state.routines[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(r.name),
                                subtitle: Text(
                                  'Ejercicios: ${r.exercises.length}',
                                ),
                                onTap: () { // Navegar al detalle
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
                ? const Center(child: Text('Sin sesiones registradas'))
                : state.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: state.sessions.length,
                        itemBuilder: (context, index) {
                          final Session s = state.sessions[index];
                          final dateStr = s.date
                              .toLocal()
                              .toString()
                              .split(' ')[0];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text('Fecha: $dateStr'),
                              subtitle: Text(
                                  'Duración: ${s.duration} min - Notas: ${s.notes ?? '-'}'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
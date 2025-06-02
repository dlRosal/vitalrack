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

  InputDecoration _darkInput(String label) {
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
        title: const Text('Entrenamiento'),
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.greenAccent,
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
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _darkInput('Nombre de la rutina'),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _level,
                      dropdownColor: const Color(0xFF2C2C2C),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: 'beginner',
                          child: Text('Beginner'),
                        ),
                        DropdownMenuItem(
                          value: 'intermediate',
                          child: Text('Intermediate'),
                        ),
                        DropdownMenuItem(
                          value: 'advanced',
                          child: Text('Advanced'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _level = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: state.loading ? null : _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700],
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.routines.isEmpty
                      ? const Center(
                          child: Text(
                            'Sin rutinas creadas',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.routines.length,
                          itemBuilder: (context, index) {
                            final Routine r = state.routines[index];
                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(r.name,
                                    style: const TextStyle(color: Colors.white)),
                                subtitle: Text(
                                  'Ejercicios: ${r.exercises.length}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: const Icon(Icons.chevron_right,
                                    color: Colors.greenAccent),
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
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
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
                            color: const Color(0xFF1E1E1E),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(
                                'Fecha: $dateStr',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Duración: ${s.duration} min - Notas: ${s.notes ?? '-'}',
                                style: const TextStyle(color: Colors.grey),
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
}

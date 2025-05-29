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
      backgroundColor: const Color(0xFF121921), // fondo oscuro elegante
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2A37),
        title: const Text('Entrenamiento'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.lightBlueAccent,
          labelColor: Colors.lightBlueAccent,
          unselectedLabelColor: Colors.grey,
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
                  decoration: InputDecoration(
                    labelText: 'Nombre de la rutina',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1F2A37),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  cursorColor: Colors.lightBlueAccent,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2A37),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: DropdownButton<String>(
                    value: _level,
                    dropdownColor: const Color(0xFF1F2A37),
                    isExpanded: true,
                    iconEnabledColor: Colors.lightBlueAccent,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: const [
                      DropdownMenuItem(
                          value: 'beginner', child: Text('Beginner')),
                      DropdownMenuItem(
                          value: 'intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(
                          value: 'advanced', child: Text('Advanced')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _level = v);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    shadowColor: Colors.lightBlueAccent.withOpacity(0.6),
                    textStyle:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2A37),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade700),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                title: Text(
                                  r.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  'Ejercicios: ${r.exercises.length}',
                                  style: const TextStyle(color: Colors.grey),
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
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : state.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.lightBlueAccent,
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.sessions.length,
                        itemBuilder: (context, index) {
                          final Session s = state.sessions[index];
                          final dateStr = s.date.toLocal().toString().split(' ')[0];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2A37),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade700),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              title: Text(
                                'Fecha: $dateStr',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w600),
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

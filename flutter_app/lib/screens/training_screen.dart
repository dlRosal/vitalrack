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

    final bgGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF04060F), Color(0xFF0A0D18)],
    );

    final cardColor = const Color(0xFF101521);
    final accentColor = const Color(0xFF1E88E5); // Más oscuro y menos brillante
    final appBarColor = const Color(0xFF0A1123);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                '⚡ ENTRENAMIENTO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              backgroundColor: appBarColor,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: accentColor.withOpacity(0.4),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: AnimatedBuilder(
                  animation: _tabController.animation!,
                  builder: (context, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabLabel("Rutinas", 0),
                        _buildTabLabel("Sesiones", 1),
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRoutinesTab(state, cardColor, accentColor),
                  _buildSessionsTab(state, cardColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabLabel(String label, int index) {
    final selected = _tabController.index == index;
    final isChanging = _tabController.animation!.value.round() == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedScale(
        scale: isChanging ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF1E88E5) : Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: selected ? 18 : 16,
              shadows: selected
                  ? [
                      const Shadow(
                        color: Color(0xFF1E88E5),
                        blurRadius: 12,
                        offset: Offset(0, 0),
                      )
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutinesTab(state, Color cardColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(controller: _nameController, label: 'Nombre de la rutina'),
          const SizedBox(height: 12),
          _buildDropdown(),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: ElevatedButton(
              onPressed: state.loading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                shadowColor: accentColor.withOpacity(0.4),
              ),
              child: state.loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '⚡ Generar Rutina',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.routines.isEmpty
                ? const Center(
                    child: Text(
                      '🚫 Sin rutinas creadas',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: state.routines.length,
                    itemBuilder: (context, index) {
                      final Routine r = state.routines[index];
                      return Card(
                        color: cardColor,
                        elevation: 8,
                        shadowColor: Colors.blueAccent.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            r.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }

  Widget _buildSessionsTab(state, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: state.sessions.isEmpty && !state.loading
          ? const Center(
              child: Text(
                '🚫 Sin sesiones registradas',
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
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          '📅 Fecha: $dateStr',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '⏱️ Duración: ${s.duration} min\n📝 Notas: ${s.notes ?? '-'}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C223A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E88E5), width: 1),
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
        color: const Color(0xFF1C223A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E88E5), width: 1),
      ),
      child: DropdownButton<String>(
        dropdownColor: const Color(0xFF1C223A),
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

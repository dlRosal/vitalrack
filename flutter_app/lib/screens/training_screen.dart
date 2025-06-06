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
  String _level = 'push';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Al montar el widget, solicitamos al provider que recupere rutinas y sesiones.
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

    // Llamamos al notifier para generar la rutina y luego limpiamos el campo de texto.
    await ref.read(trainingProvider.notifier).generateRoutine(name, _level);
    _nameController.clear();
  }

  Future<void> _addSession() async {
    // Obtenemos la lista de rutinas actuales desde el estado.
    final routines = ref.read(trainingProvider).routines;
    if (routines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea una rutina')),
      );
      return;
    }

    // Por defecto seleccionamos la primera rutina de la lista.
    Routine? selected = routines.first;

    // Abrimos un diálogo para que el usuario seleccione sobre qué rutina registrar la sesión.
    final Routine? routine = await showDialog<Routine>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selecciona rutina'),
              content: DropdownButton<Routine>(
                value: selected,
                isExpanded: true,
                items: routines
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selected = value);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, selected),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );

    // Si el usuario confirma una rutina, navegamos a la pantalla de registro de sesiones.
    if (routine != null && mounted) {
      Navigator.pushNamed(context, '/training/log', arguments: routine);
    }
  }

  Future<void> _deleteRoutine(String id) async {
    await ref.read(trainingProvider.notifier).deleteRoutine(id);
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
    final accentColor = const Color(0xFF1E88E5);
    final appBarColor = const Color(0xFF0A1123);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'ENTRENAMIENTO',
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
          // Campo de texto para el nombre de la nueva rutina
          _buildInputField(controller: _nameController, label: 'Nombre de la rutina'),
          const SizedBox(height: 12),

          // Dropdown para seleccionar nivel (beginner/intermediate/advanced)
          _buildDropdown(),
          const SizedBox(height: 12),

          // Botón para generar la rutina
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: ElevatedButton(
              onPressed: state.loading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A), // Azul muy oscuro
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(
                    color: Color(0xFF00FFFF), // Neón azul cian
                    width: 2,
                  ),
                ),
                elevation: 20,
                shadowColor: const Color(0xFF00FFFF).withOpacity(0.6),
              ),
              child: state.loading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFFF)),
                      ),
                    )
                  : const Text(
                      'Generar Rutina',
                      style: TextStyle(
                        color: Color(0xFF00FFFF), // Neón cian
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Color(0xFF00FFFF),
                            blurRadius: 8,
                            offset: Offset(0, 0),
                          ),
                        ],
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
                                                    trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                            onPressed: () => _deleteRoutine(r.id),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón para registrar sesión
          ElevatedButton.icon(
            onPressed: _addSession,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Registrar sesión',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001F3F), // Azul muy oscuro tipo LED
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: const Color(0xFF00BFFF), // Azul brillante tipo neón
              elevation: 12,
            ).copyWith(
              overlayColor: MaterialStateProperty.all(const Color(0xFF005F9E)), // efecto al presionar
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
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
                              onTap: () {
                                // Al pulsar una sesión, navegamos a /training/session pasándole la sesión completa
                                Navigator.pushNamed(
                                  context,
                                  '/training/session',
                                  arguments: s,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E88E5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _level,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: const Color(0xFF101521),
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: [
            _buildDropdownItem('push', 'Pecho | Triceps | Hombro'),
            _buildDropdownItem('pull', 'Espalda | Biceps'),
            _buildDropdownItem('leg', 'Pierna'),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _level = value;
              });
            }
          },
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String text) {
    return DropdownMenuItem<String>(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

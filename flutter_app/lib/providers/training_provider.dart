// lib/providers/training_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/training_service.dart';
import '../models/routine.dart';
import '../models/session.dart';
import 'auth_provider.dart';

/// Estado de entrenamiento: rutinas, sesiones, carga y error
class TrainingState {
  final List<Routine> routines;
  final List<Session> sessions;
  final bool loading;
  final String? error;

  TrainingState({
    this.routines = const [],
    this.sessions = const [],
    this.loading = false,
    this.error,
  });

  TrainingState copyWith({
    List<Routine>? routines,
    List<Session>? sessions,
    bool? loading,
    String? error,
  }) {
    return TrainingState(
      routines: routines ?? this.routines,
      sessions: sessions ?? this.sessions,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// Notifier que maneja generación, listado y log de sesiones
class TrainingNotifier extends StateNotifier<TrainingState> {
  final TrainingService _service;
  TrainingNotifier(this._service) : super(TrainingState());

  Future<void> generateRoutine(String name, String level) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _service.generateRoutine(name: name, level: level);
      final routine = Routine.fromJson(data);
      state = state.copyWith(
        routines: [routine, ...state.routines],
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> fetchRoutines() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _service.fetchRoutines();
      final items = list.map((e) => Routine.fromJson(e)).toList();
      state = state.copyWith(routines: items, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> logSession(String routineId, int duration,
      List<Map<String, dynamic>> entries,
      {String? notes}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _service.logSession(
          routineId: routineId,
          duration: duration,
          entries: entries,
          notes: notes);
      final session = Session.fromJson(data);
      state = state.copyWith(
        sessions: [session, ...state.sessions],
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> fetchSessions() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _service.fetchSessions();
      final items = list.map((e) => Session.fromJson(e)).toList();
      state = state.copyWith(sessions: items, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
  
  Future<void> deleteRoutine(String id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.deleteRoutine(id);
      state = state.copyWith(
        routines: state.routines.where((r) => r.id != id).toList(),
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

/// Provider de TrainingService con token
final trainingServiceProvider = Provider<TrainingService>((ref) {
  final token = ref.watch(authProvider).token!;
  return TrainingService(token: token);
});

/// Provider de TrainingNotifier
final trainingProvider =
    StateNotifierProvider<TrainingNotifier, TrainingState>((ref) {
  final svc = ref.watch(trainingServiceProvider);
  return TrainingNotifier(svc);
});

// flutter_app/lib/providers/nutrition_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/nutrition_service.dart';
import '../models/food.dart';
import '../models/consumption.dart';
import 'auth_provider.dart'; // para acceder al token

/// Estado de nutrición: resultados, historial, carga y error
class NutritionState {
  final List<Food> foods;
  final List<Consumption> history;
  final bool loading;
  final String? error;

  NutritionState({
    this.foods = const [],
    this.history = const [],
    this.loading = false,
    this.error,
  });

  NutritionState copyWith({
    List<Food>? foods,
    List<Consumption>? history,
    bool? loading,
    String? error,
  }) {
    return NutritionState(
      foods: foods ?? this.foods,
      history: history ?? this.history,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// Notifier que maneja búsqueda y registro de consumos
class NutritionNotifier extends StateNotifier<NutritionState> {
  final NutritionService _service;
  NutritionNotifier(this._service) : super(NutritionState());

  Future<void> search(String query) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await _service.searchFoods(query);
      state = state.copyWith(foods: results, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> logConsumption(String foodId, int qty) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.logConsumption(foodId: foodId, quantity: qty);
      // Recargar historial tras registrar consumo
      final historyList = await _service.fetchConsumptionHistory();
      final items = historyList.map((e) => Consumption.fromJson(e)).toList();
      state = state.copyWith(history: items, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> fetchHistory() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final historyList = await _service.fetchConsumptionHistory();
      final items = historyList.map((e) => Consumption.fromJson(e)).toList();
      state = state.copyWith(history: items, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> deleteConsumption(String id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.deleteConsumption(id);
      final historyList = await _service.fetchConsumptionHistory();
      final items = historyList.map((e) => Consumption.fromJson(e)).toList();
      state = state.copyWith(history: items, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> clearHistory() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.clearHistory();
      state = state.copyWith(history: [], loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  void clearFoods() {
    state = state.copyWith(foods: []);
  }
}

/// Provider de NutritionService que inyecta el token
final nutritionServiceProvider = Provider<NutritionService>((ref) {
  final token = ref.watch(authProvider).token!;
  return NutritionService(token: token);
});

/// Provider de NutritionNotifier
final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  final svc = ref.watch(nutritionServiceProvider);
  return NutritionNotifier(svc);
});

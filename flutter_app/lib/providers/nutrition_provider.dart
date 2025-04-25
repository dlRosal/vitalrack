// lib/providers/nutrition_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/nutrition_service.dart';
import '../models/food.dart';
import 'auth_provider.dart'; // para acceder al token

/// Estado de nutrición: resultados, carga y error
class NutritionState {
  final List<Food> foods;
  final bool loading;
  final String? error;

  NutritionState({this.foods = const [], this.loading = false, this.error});

  NutritionState copyWith({List<Food>? foods, bool? loading, String? error}) {
    return NutritionState(
      foods: foods ?? this.foods,
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
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
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

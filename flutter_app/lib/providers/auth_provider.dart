// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Provee la instancia de AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Estado de autenticación: token, usuario, carga y error
class AuthState {
  final String? token;
  final User? user;
  final bool loading;
  final String? error;

  AuthState({
    this.token,
    this.user,
    this.loading = false,
    this.error,
  });

  AuthState copyWith({
    String? token,
    User? user,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// Notifier que maneja login, registro, logout y carga del perfil
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  AuthNotifier(this._service) : super(AuthState());

  /// Guarda el token y carga los datos del usuario
  Future<void> _saveTokenAndLoadUser(String token) async {
    state = state.copyWith(token: token, loading: true, error: null);
    try {
      final user = await _service.getProfile(token);
      state = state.copyWith(user: user, loading: false, token: token);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  /// Llama al endpoint de login, guarda token y carga usuario
  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _service.login(email: email, password: password);
      await _saveTokenAndLoadUser(token);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  /// Llama al endpoint de registro, guarda token y carga usuario
  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _service.register(email: email, password: password);
      await _saveTokenAndLoadUser(token);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  /// Limpia token y usuario al hacer logout
  Future<void> logout() async {
    state = AuthState();
  }

  /// Refresca los datos del usuario desde el backend
  Future<void> loadUser() async {
    final token = state.token;
    if (token == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _service.getProfile(token);
      state = state.copyWith(user: user, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  /// Permite actualizar el perfil y recargar el usuario
  Future<void> updateProfile({
    String? username,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? goal,
    int? trainingDays,
  }) async {
    final token = state.token;
    if (token == null) {
      state = state.copyWith(error: 'No autenticado');
      return;
    }

    state = state.copyWith(loading: true, error: null);
    try {
      final updatedUser = await _service.updateProfile(
        token: token,
        username: username,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        goal: goal,
        trainingDays: trainingDays,
      );
      state = state.copyWith(user: updatedUser, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

/// Provider de AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final svc = ref.watch(authServiceProvider);
  return AuthNotifier(svc);
});

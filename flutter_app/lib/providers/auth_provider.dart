// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Instancia de AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Estado de autenticación: token, carga y error
class AuthState {
  final String? token;
  final bool loading;
  final String? error;

  AuthState({this.token, this.loading = false, this.error});

  AuthState copyWith({String? token, bool? loading, String? error}) {
    return AuthState(
      token: token ?? this.token,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// Notifier que maneja login, register y logout
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  AuthNotifier(this._service) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _service.login(email: email, password: password);
      state = state.copyWith(token: token, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _service.register(email: email, password: password);
      state = state.copyWith(token: token, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  void logout() {
    state = AuthState();
  }
}

/// Provider de AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final svc = ref.watch(authServiceProvider);
  return AuthNotifier(svc);
});

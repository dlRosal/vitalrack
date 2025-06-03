// flutter_app/lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

/// Estado que contiene token y objeto UserData
class AuthState {
  final String? token;
  final bool loading;
  final String? error;
  final User? user;

  AuthState({this.token, this.loading = false, this.error, this.user});

  AuthState copyWith({
    String? token,
    bool? loading,
    String? error,
    User? user,
  }) {
    return AuthState(
      token: token ?? this.token,
      loading: loading ?? this.loading,
      error: error,
      user: user ?? this.user,
    );
  }
}

/// Instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// El StateNotifier que maneja login, register, fetchMe y logout
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  SharedPreferences? _prefs;

  AuthNotifier(this._service) : super(AuthState()) {
    _loadTokenFromPrefs();
  }

  Future<void> _loadTokenFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final savedToken = _prefs?.getString('auth_token');
    if (savedToken != null && savedToken.isNotEmpty) {
      state = state.copyWith(token: savedToken);
      await fetchMe();
    }
  }

  Future<void> _saveToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    await _prefs?.remove('auth_token');
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _service.login(email: email, password: password);
      state = state.copyWith(token: token, loading: false);
      await _saveToken(token);
      await fetchMe();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        loading: false,
        token: null,
        user: null,
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _service.register(email: email, password: password);
      state = state.copyWith(token: token, loading: false);
      await _saveToken(token);
      await fetchMe();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        loading: false,
        token: null,
        user: null,
      );
    }
  }

  Future<void> fetchMe() async {
    final currentToken = state.token;
    if (currentToken == null) return;

    state = state.copyWith(loading: true, error: null);
    try {
      final userData = await _service.getProfile(token: currentToken);
      state = state.copyWith(user: userData, loading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        loading: false,
        token: null,
        user: null,
      );
      await _clearToken();
    }
  }

  Future<void> logout() async {
    state = AuthState();
    await _clearToken();
  }
}

/// Provider principal
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});

/// Provider que expone solo el token (String?)
final tokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
});

/// Provider que expone solo el objeto User?
final userProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

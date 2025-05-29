// flutter_app/lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  /// Esto lee en tiempo de compilación el dart-define o usa localhost.
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:10000',
  );

  /// La URL base para /auth
  final String _baseUrl;

  /// Construye el servicio. Si quieres override manual, pásalo.
  AuthService({String? baseUrl})
      : _baseUrl = baseUrl ?? '$_apiBase/auth';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  Future<String> register({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al registrar usuario: ${response.body}');
    }
    return jsonDecode(response.body)['token'] as String;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
    return jsonDecode(response.body)['token'] as String;
  }

  Future<void> logout() async {
    final uri = Uri.parse('$_baseUrl/logout');
    final response = await http.post(uri, headers: _headers);
    if (response.statusCode != 204) {
      throw Exception('Error al cerrar sesión: ${response.body}');
    }
  }
}
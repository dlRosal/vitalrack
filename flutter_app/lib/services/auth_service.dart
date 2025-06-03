// flutter_app/lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart'; // Asegúrate de que exista este archivo con tu clase User

class AuthService {
  /// Esto lee en tiempo de compilación el dart-define o usa localhost.
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:10000',
  );

  /// La URL base para /auth
  final String _baseUrl;

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  AuthService({String? baseUrl})
      : _baseUrl = baseUrl ?? '$_apiBase/auth';

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

  /// GET /auth/me → devuelve un JSON con los datos del usuario (sin password)
  Future<User> getProfile({ required String token }) async {
    final uri = Uri.parse('$_baseUrl/me');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al obtener perfil: ${response.body}');
    }
    final data = jsonDecode(response.body)['user'] as Map<String, dynamic>;
    return User.fromJson(data);
  }
}

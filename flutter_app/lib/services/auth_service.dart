import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para autenticación: login y registro de usuarios.
class AuthService {
  // URL base para endpoints de autenticación
  final String _baseUrl;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Constructor, opcionalmente configurar baseUrl
  AuthService({String baseUrl = 'http://localhost:4000/auth'})
      : _baseUrl = baseUrl;

  /// Registra un nuevo usuario y devuelve el token JWT
  Future<String> register({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('\$_baseUrl/register');
    final body = jsonEncode({'email': email, 'password': password});
    final response = await http.post(uri, headers: _headers, body: body);
    if (response.statusCode != 201) {
      throw Exception('Error al registrar usuario: \${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['token'] as String;
  }

  /// Loguea un usuario existente y devuelve el token JWT
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login');
    final body = jsonEncode({'email': email, 'password': password});
    final response = await http.post(uri, headers: _headers, body: body);
    if (response.statusCode != 200) {
      throw Exception('Error al iniciar sesión: \${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['token'] as String;
  }
}

// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  /// Esto lee en tiempo de compilación el dart-define o usa localhost.
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:10000',
  );

  /// La URL base para /auth
  final String _baseUrl;

  /// Construye el servicio. Si quieres override manual, pásalo.
  AuthService({String? baseUrl}) : _baseUrl = baseUrl ?? '$_apiBase/auth';

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

  /// Obtiene el perfil completo del usuario autenticado (GET /auth/me)
  Future<User> getProfile(String token) async {
    final uri = Uri.parse('$_baseUrl/me');
    final response = await http.get(
      uri,
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al obtener perfil: ${response.body}');
    }
    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    // El endpoint devuelve { user: { ... } }
    final userJson = jsonMap['user'] as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  /// Actualiza el perfil del usuario autenticado (PUT /auth/me)
  Future<User> updateProfile({
  required String token,
  String? username,
  String? gender,
  int? age,
  double? height,
  double? weight,
}) async {
  final uri = Uri.parse('$_baseUrl/me');
  final body = {
    if (username != null) 'username': username,
    if (gender != null) 'gender': gender,
    if (age != null) 'age': age,
    if (height != null) 'height': height,
    if (weight != null) 'weight': weight,
  };
  final response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );
  if (response.statusCode != 200) {
    throw Exception('Error al actualizar perfil: ${response.body}');
  }
  final data = jsonDecode(response.body)['user'] as Map<String, dynamic>;
  return User.fromJson(data);
}

}

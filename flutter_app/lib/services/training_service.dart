// flutter_app/lib/services/training_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para consumir los endpoints de Entrenamiento del backend.
class TrainingService {
  /// Toma la URL base de la variable --dart-define o usa localhost en dev.
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:10000',
  );

  final Map<String, String> _headers;

  /// Crea el servicio con el token JWT para las cabeceras.
  TrainingService({ required String token })
      : _headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

  /// Genera una nueva rutina.
  Future<Map<String, dynamic>> generateRoutine({
    required String name,
    required String level,
  }) async {
    final uri = Uri.parse('$_baseUrl/training/generate');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'name': name, 'level': level}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al generar rutina: ${response.body}');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['routine']
        as Map<String, dynamic>;
  }

  /// Obtiene las rutinas del usuario autenticado.
  Future<List<Map<String, dynamic>>> fetchRoutines() async {
    final uri = Uri.parse('$_baseUrl/training/routines');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener rutinas: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(json['routines'] as List);
  }

  /// Registra una sesión de entrenamiento.
  Future<Map<String, dynamic>> logSession({
    required String routineId,
    required int duration,
    required List<Map<String, dynamic>> entries,
    String? notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/training/log');
    final payload = {
      'routineId': routineId,
      'duration': duration,
      'entries': entries,
      if (notes != null) 'notes': notes,
    };
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al registrar sesión: ${response.body}');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['session']
        as Map<String, dynamic>;
  }

  /// Obtiene las sesiones del usuario autenticado.
  Future<List<Map<String, dynamic>>> fetchSessions() async {
    final uri = Uri.parse('$_baseUrl/training/sessions');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener sesiones: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(json['sessions'] as List);
  }
  
  /// Elimina una rutina existente
  Future<void> deleteRoutine(String id) async {
    final uri = Uri.parse('$_baseUrl/training/routines/$id');
    final response = await http.delete(uri, headers: _headers);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar rutina: ${response.body}');
    }
  }
}

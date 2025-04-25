import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para consumir los endpoints de Entrenamiento del backend.
class TrainingService {
  // URL base al endpoint de training (ajustar según entorno/emulador)
  final String _baseUrl;
  final Map<String, String> _headers;

  /// Constructor que recibe el token JWT para autenticación.
  TrainingService({
    required String token,
    String baseUrl = 'http://localhost:4000/training',
  })  : _baseUrl = baseUrl,
        _headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

  /// Genera una nueva rutina en base a un nombre y nivel.
  /// Retorna un Map con la rutina creada.
  Future<Map<String, dynamic>> generateRoutine({
    required String name,
    required String level,
  }) async {
    final uri = Uri.parse('$_baseUrl/generate');
    final body = jsonEncode({'name': name, 'level': level});
    final response = await http.post(uri, headers: _headers, body: body);
    if (response.statusCode != 201) {
      throw Exception('Error al generar rutina: \${response.body}');
    }
    return jsonDecode(response.body)['routine'] as Map<String, dynamic>;
  }

  /// Obtiene las rutinas del usuario autenticado.
  Future<List<Map<String, dynamic>>> fetchRoutines() async {
    final uri = Uri.parse('\$_baseUrl/routines');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener rutinas: \${response.body}');
    }
    return List<Map<String, dynamic>>.from(
      jsonDecode(response.body)['routines'],
    );
  }

  /// Registra una sesión de entrenamiento.
  /// `entries` es lista de mapas: { exerciseName, sets, reps, weight }.
  Future<Map<String, dynamic>> logSession({
    required String routineId,
    required int duration,
    required List<Map<String, dynamic>> entries,
    String? notes,
  }) async {
    final uri = Uri.parse('\$_baseUrl/log');
    final payload = {
      'routineId': routineId,
      'duration': duration,
      'entries': entries,
      if (notes != null) 'notes': notes,
    };
    final response =
        await http.post(uri, headers: _headers, body: jsonEncode(payload));
    if (response.statusCode != 201) {
      throw Exception('Error al registrar sesión: \${response.body}');
    }
    return jsonDecode(response.body)['session'] as Map<String, dynamic>;
  }

  /// Obtiene las sesiones de entrenamiento del usuario autenticado.
  Future<List<Map<String, dynamic>>> fetchSessions() async {
    final uri = Uri.parse('\$_baseUrl/sessions');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener sesiones: \${response.body}');
    }
    return List<Map<String, dynamic>>.from(
      jsonDecode(response.body)['sessions'],
    );
  }
}

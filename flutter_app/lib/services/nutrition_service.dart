// flutter_app/lib/services/nutrition_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';

/// Servicio para consumir los endpoints de Nutrición del backend.
class NutritionService {
  /// Toma la URL base de la variable --dart-define o usa localhost en dev.
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:10000',
  );

  final Map<String, String> _headers;

  /// Crea el servicio con el token JWT para las cabeceras.
  NutritionService({ required String token })
      : _headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

  /// Busca alimentos por nombre.
  Future<List<Food>> searchFoods(String query) async {
    final uri = Uri.parse(
      '$_baseUrl/nutrition/search?q=${Uri.encodeComponent(query)}',
    );
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Error al buscar alimentos: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = json['foods'] as List<dynamic>;
    return items
        .map((e) => Food.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Registra un consumo de un alimento.
  Future<void> logConsumption({
    required String foodId,
    required int quantity,
  }) async {
    final uri = Uri.parse('$_baseUrl/nutrition/log');
    final body = jsonEncode({'foodId': foodId, 'quantity': quantity});
    final response = await http.post(uri, headers: _headers, body: body);
    if (response.statusCode != 201) {
      throw Exception('Error al registrar consumo: ${response.body}');
    }
  }

  /// Obtiene el historial de consumos del usuario.
  Future<List<Map<String, dynamic>>> fetchConsumptionHistory() async {
    final uri = Uri.parse('$_baseUrl/nutrition/history');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener historial: ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(json['history'] as List<dynamic>);
  }
  
  /// Elimina una entrada de consumo concreta
  Future<void> deleteConsumption(String id) async {
    final uri = Uri.parse('$_baseUrl/nutrition/history/$id');
    final response = await http.delete(uri, headers: _headers);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar consumo: ${response.body}');
    }
  }

  /// Borra todo el historial de consumos del usuario
  Future<void> clearHistory() async {
    final uri = Uri.parse('$_baseUrl/nutrition/history');
    final response = await http.delete(uri, headers: _headers);
    if (response.statusCode != 204) {
      throw Exception('Error al borrar historial: ${response.body}');
    }
  }
}

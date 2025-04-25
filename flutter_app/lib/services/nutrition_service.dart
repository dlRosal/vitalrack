import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';

/// Servicio para consumir los endpoints de Nutrición del backend.
class NutritionService {
  /// URL base para nutrición (search y log)
  final String _baseUrl;
  final Map<String, String> _headers;

  /// Crea el servicio con el token JWT y opcionalmente la URL base
  NutritionService({
    required String token,
    String baseUrl = 'http://localhost:4000/nutrition',
  })  : _baseUrl = baseUrl,
        _headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

  /// Busca alimentos por nombre.
  /// Llama a GET /nutrition/search?q=<query> y devuelve lista de Food.
  Future<List<Food>> searchFoods(String query) async {
    final uri = Uri.parse('$_baseUrl/search?q=\${Uri.encodeComponent(query)}');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Error al buscar alimentos: \${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['foods'] as List<dynamic>;
    return items.map((e) => Food.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Registra un consumo de un alimento.
  /// Llama a POST /nutrition/log con body { foodId, quantity }.
  Future<void> logConsumption({
    required String foodId,
    required int quantity,
  }) async {
    final uri = Uri.parse('\$_baseUrl/log');
    final body = jsonEncode({'foodId': foodId, 'quantity': quantity});
    final response = await http.post(uri, headers: _headers, body: body);
    if (response.statusCode != 201) {
      throw Exception('Error al registrar consumo: \${response.body}');
    }
  }
}

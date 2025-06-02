import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';
import '../models/food.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      await ref.read(nutritionProvider.notifier).search(query);
    }
  }

  Future<void> _logConsumption(String foodId) async {
    await ref.read(nutritionProvider.notifier).logConsumption(foodId, 100);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consumo registrado'),
        backgroundColor: Color(0xFF2E7D32), // verde oscuro
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);

    final bgColor = const Color(0xFF0F1A12); // Fondo general con tinte verde oscuro
    final cardColor = const Color(0xFF1B2A21); // Tarjetas
    final accent = const Color(0xFF66BB6A); // Verde acento

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Nutrición'),
        backgroundColor: const Color(0xFF1C2B21),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Buscar alimento',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Icon(Icons.search, color: accent),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.search, color: accent),
                  onPressed: state.loading ? null : _search,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.loading)
              CircularProgressIndicator(color: accent),
            if (state.error != null)
              Text(
                state.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state.foods.length,
                itemBuilder: (context, index) {
                  final Food food = state.foods[index];
                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        food.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Cal: ${food.calories} | P: ${food.protein}g | C: ${food.carbs}g | F: ${food.fat}g',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle, color: accent, size: 28),
                        tooltip: 'Añadir consumo',
                        onPressed: () => _logConsumption(food.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

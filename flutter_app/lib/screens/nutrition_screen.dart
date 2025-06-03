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
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);

    final bgColor = const Color(0xFF0A0F0A);
    final cardColor = const Color(0xFF131E17);
    final accent = const Color(0xFF4CAF50); // Verde más vivo
    final glow = Colors.greenAccent.withOpacity(0.2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2B1E),
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        title: const Text(
          'NUTRICIÓN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: glow,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar alimento',
                        hintStyle: const TextStyle(color: Colors.white70),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Material(
                    color: accent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: state.loading ? null : _search,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                  return GestureDetector(
                    onTapDown: (_) {}, // para animación si quieres
                    child: Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(vertical: 6),
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

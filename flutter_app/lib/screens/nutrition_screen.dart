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
    final accent = const Color(0xFF4CAF50); // Verde vivo
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
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: glow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar alimento...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: state.loading ? null : _search,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      title: Text(
                        food.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          'Cal: ${food.calories} | Prot: ${food.protein}g | Carb: ${food.carbs}g | Grasa: ${food.fat}g',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle, color: accent, size: 32),
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

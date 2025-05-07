// lib/screens/nutrition_screen.dart
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consumo registrado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrición')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar alimento',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: state.loading ? null : _search,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.loading) const CircularProgressIndicator(),
            if (state.error != null)
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state.foods.length,
                itemBuilder: (context, index) {
                  final Food food = state.foods[index];
                  return Card(
                    child: ListTile(
                      title: Text(food.name),
                      subtitle: Text(
                        'Cal: \${food.calories}, P: \${food.protein}, C: \${food.carbs}, F: \${food.fat}'
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
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

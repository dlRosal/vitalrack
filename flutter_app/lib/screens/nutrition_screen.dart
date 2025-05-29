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
      const SnackBar(content: Text('Consumo registrado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121921), // fondo oscuro azulado suave
      appBar: AppBar(
        title: const Text('Nutrición'),
        backgroundColor: const Color(0xFF1F2A37),
        elevation: 2,
        centerTitle: true,
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
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1F2A37),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    cursorColor: Colors.lightBlueAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: state.loading ? Colors.grey.shade700 : Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: state.loading
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.lightBlueAccent.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: state.loading ? null : _search,
                    splashRadius: 28,
                    tooltip: 'Buscar',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.loading)
              const CircularProgressIndicator(
                color: Colors.lightBlueAccent,
              ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state.foods.length,
                itemBuilder: (context, index) {
                  final Food food = state.foods[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2A37),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade700),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        food.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        'Cal: ${food.calories}, P: ${food.protein}, C: ${food.carbs}, F: ${food.fat}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.lightBlueAccent.withOpacity(0.6),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => _logConsumption(food.id),
                          tooltip: 'Registrar consumo',
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

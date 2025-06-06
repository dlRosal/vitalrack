// flutter_app/lib/screens/nutrition_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';
import '../providers/auth_provider.dart';
import '../models/food.dart';
import '../models/consumption.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  // Valor por defecto para el límite calórico si no hay datos
  static const int defaultMaxCalories = 2000;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Controlador para animaciones de brillo y pulso
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Carga historial inicial
    Future.microtask(
      () => ref.read(nutritionProvider.notifier).fetchHistory(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() => _hasSearched = true);
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

  Future<void> _deleteConsumption(String id) async {
    await ref.read(nutritionProvider.notifier).deleteConsumption(id);
  }

  Future<void> _clearHistory() async {
    await ref.read(nutritionProvider.notifier).clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);
    final user = ref.watch(authProvider).user;

    final bgColor = const Color(0xFF0A0F0A);
    final cardColor = const Color(0xFF131E17);
    final accent = const Color(0xFF4CAF50); // Verde vivo

    // Total de calorías consumidas
    final totalCaloriesConsumed = state.history.fold<double>(
      0,
      (sum, c) => sum + c.food.calories * c.quantity / 100,
    );

    // Cálculo simple de calorías diarias según perfil
    int maxCalories = defaultMaxCalories;
    if (user != null &&
        user.weight != null &&
        user.height != null &&
        user.age != null) {
      double bmr =
          10 * user.weight! + 6.25 * user.height! - 5 * user.age!;
      if (user.gender == 'male') {
        bmr += 5;
      } else {
        bmr -= 161;
      }
      double activity = 1.2;
      final days = user.trainingDays ?? 3;
      if (days >= 5) {
        activity = 1.725;
      } else if (days >= 3) {
        activity = 1.55;
      } else if (days >= 1) {
        activity = 1.375;
      }
      double goalFactor = 1.0;
      if (user.goal == 'bulk') goalFactor = 1.1;
      if (user.goal == 'cut') goalFactor = 0.9;

      maxCalories = (bmr * activity * goalFactor).round();
    }

    // Objetivos de macronutrientes calculados de forma sencilla
    double weight = user?.weight ?? 70;
    double proteinGoalPerKg = 1.8;
    if (user?.goal == 'bulk') proteinGoalPerKg = 2.0;
    if (user?.goal == 'cut') proteinGoalPerKg = 2.2;
    final proteinGoal = weight * proteinGoalPerKg;
    final fatGoal = weight * 1.0;
    final carbsGoal = (maxCalories - (proteinGoal * 4 + fatGoal * 9)) / 4;

    final proteinConsumed = state.history.fold<double>(
      0,
      (s, c) => s + c.food.protein * c.quantity / 100,
    );
    final carbsConsumed = state.history.fold<double>(
      0,
      (s, c) => s + c.food.carbs * c.quantity / 100,
    );
    final fatConsumed = state.history.fold<double>(
      0,
      (s, c) => s + c.food.fat * c.quantity / 100,
    );

    final progress =
        (totalCaloriesConsumed / maxCalories).clamp(0, 1).toDouble();

    final diff = totalCaloriesConsumed - maxCalories;
    Color barColor;
    if (diff <= 50) {
      barColor = const Color(0xFF64DD17);
    } else if (diff <= 150) {
      barColor = Colors.orange;
    } else if (diff <= 250) {
      barColor = Colors.deepOrange;
    } else if (diff <= 350) {
      barColor = Colors.red;
    } else {
      barColor = Colors.red.shade900;
    }

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
                          color: Colors.greenAccent.withOpacity(0.2),
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
                        suffixIcon: IconButton(
                          icon:
                              const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(nutritionProvider.notifier)
                                .clearFoods();
                            setState(() => _hasSearched = false);
                          },
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

            const SizedBox(height: 12),

            // Texto explicativo sutil
            const Text(
              'Selecciona alimentos para añadirlos a tu dieta. '
              'Se contabilizan calorías, proteínas, carbohidratos y grasas consumidas.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            if (state.loading) CircularProgressIndicator(color: accent),

            if (state.error != null)
              Text(
                state.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),

            const SizedBox(height: 12),

            // Listado de alimentos o historial
            Expanded(
              child: state.foods.isNotEmpty
                  ? ListView.builder(
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
                            contentPadding:
                                const EdgeInsets.symmetric(
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
                              padding:
                                  const EdgeInsets.only(top: 6.0),
                              child: Text(
                                'Cal: ${food.calories} | Prot: ${food.protein}g | Carb: ${food.carbs}g | Grasa: ${food.fat}g',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.add_circle,
                                  color: accent, size: 32),
                              tooltip: 'Añadir consumo',
                              onPressed: () =>
                                  _logConsumption(food.id),
                            ),
                          ),
                        );
                      },
                    )
                  : _hasSearched && !state.loading
                      ? const Center(
                          child: Text(
                            'Sin resultados para esa búsqueda',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.history.length,
                          itemBuilder: (context, index) {
                            final item = state.history[index];
                            final food = item.food;
                            return Card(
                              color: cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              elevation: 10,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10),
                                title: Text(
                                  food.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    'Cantidad: ${item.quantity}g | Calorías: ${(food.calories * item.quantity / 100).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                                  onPressed: () =>
                                      _deleteConsumption(item.id),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed:
                  state.history.isEmpty ? null : _clearHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Nuevo Día'),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    'MACROS (g)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroColumn(
                        'Objetivo',
                        proteinGoal,
                        carbsGoal,
                        fatGoal,
                      ),
                      _buildMacroColumn(
                        'Consumido',
                        proteinConsumed,
                        carbsConsumed,
                        fatConsumed,
                      ),
                      _buildMacroColumn(
                        'Restante',
                        proteinGoal - proteinConsumed,
                        carbsGoal - carbsConsumed,
                        fatGoal - fatConsumed,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // NUEVA BARRA DE CALORÍAS ESPECTACULAR
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Para el brillo animado: un valor que va de -1 a 2 para el gradiente animado
                final animationValue =
                    _animationController.value * 3 - 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Calorías consumidas: $totalCaloriesConsumed / $maxCalories kcal',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            color: Colors.greenAccent,
                            blurRadius: 8,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Barra con brillo y pulso
                    Transform.scale(
                      scale: 1 +
                          0.05 *
                              (1 -
                                  (progress - 0.5).abs() * 2),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Container(
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(20),
                                color: Colors.grey[800],
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 3),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            // Barra de progreso con degradado dinámico
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: 25,
                                  width: constraints.maxWidth *
                                      progress,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        barColor.withOpacity(0.7),
                                        barColor,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: barColor
                                            .withOpacity(0.6),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset:
                                            const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment(
                                            -1 + animationValue,
                                            0),
                                        end: Alignment(
                                            animationValue, 0),
                                        colors: [
                                          Colors.white
                                              .withOpacity(0.2),
                                          Colors.white
                                              .withOpacity(0.8),
                                          Colors.white
                                              .withOpacity(0.2),
                                        ],
                                        stops: const [
                                          0.4,
                                          0.5,
                                          0.6
                                        ],
                                      ).createShader(rect);
                                    },
                                    blendMode:
                                        BlendMode.lighten,
                                    child: Container(
                                      color: Colors.white
                                          .withOpacity(0.15),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Partículas de brillo animadas
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _SparklePainter(
                                  progress: progress,
                                  animationValue:
                                      animationValue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroColumn(
      String label, double p, double c, double f) {
    TextStyle style =
        const TextStyle(color: Colors.white70, fontSize: 14);
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('P: ${p.toStringAsFixed(0)}', style: style),
        Text('C: ${c.toStringAsFixed(0)}', style: style),
        Text('G: ${f.toStringAsFixed(0)}', style: style),
      ],
    );
  }
}

// Pintor personalizado para chispas brillantes animadas
class _SparklePainter extends CustomPainter {
  final double progress;
  final double animationValue;

  _SparklePainter({
    required this.progress,
    required this.animationValue,
  });

  final _sparklePaint = Paint()
    ..color = Colors.white.withOpacity(0.8)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * progress;
    final height = size.height;

    // Dibujar algunas chispas distribuidas a lo largo de la barra de progreso
    final sparkleCount = 7;
    final sparkleRadius = 3.0;

    for (int i = 0; i < sparkleCount; i++) {
      // Posición x base para cada chispa
      final baseX = width / sparkleCount * i + sparkleRadius * 2;

      // Desplazamiento horizontal oscilante para la animación de brillo
      final offsetX = (animationValue * 100) % width;

      final x = (baseX + offsetX) % width;

      final y = height / 2 +
          (3 * (i.isEven ? 1 : -1)) *
              (0.5 - (animationValue - i / sparkleCount).abs())
                  .abs();

      // Dibuja círculo brillo
      canvas.drawCircle(Offset(x, y), sparkleRadius, _sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.progress != progress;
  }
}

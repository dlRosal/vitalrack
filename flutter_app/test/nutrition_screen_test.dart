import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/providers/nutrition_provider.dart';
import 'package:flutter_app/screens/nutrition_screen.dart';

/// Stub para NutritionNotifier sin timers ni delays
class FakeNutritionNotifier extends StateNotifier<NutritionState>
    implements NutritionNotifier {
  FakeNutritionNotifier() : super(NutritionState());

  @override
  Future<void> search(String query) async {
    // Simula búsqueda instantánea
    state = state.copyWith(
      loading: true,
      foods: [],
    );
    // Entrega ein alimento estático
    state = state.copyWith(
      loading: false,
      foods: [
        Food(
          id: '1',
          externalId: 'ext1',
          name: 'Test Food',
          calories: 100,
          protein: 5,
          carbs: 10,
          fat: 1,
        ),
      ],
    );
  }

  @override
  Future<void> logConsumption(String foodId, int quantity) async {
    // No modifika estado
  }
}

void main() {
  group('NutritionScreen Widget Tests', () {
    testWidgets('renders search input and button', (WidgetTester tester) async {
      final notifier = FakeNutritionNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [nutritionProvider.overrideWith((ref) => notifier)],
          child: const MaterialApp(home: NutritionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Debe haber un campo de texto y un icono de búsqueda
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading=true state', (WidgetTester tester) async {
      final notifier = FakeNutritionNotifier();
      notifier.state = notifier.state.copyWith(loading: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [nutritionProvider.overrideWith((ref) => notifier)],
          child: const MaterialApp(home: NutritionScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('performs search and displays food list', (WidgetTester tester) async {
      final notifier = FakeNutritionNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [nutritionProvider.overrideWith((ref) => notifier)],
          child: const MaterialApp(home: NutritionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Ejecuta la búsqueda
      await notifier.search('apple');
      await tester.pumpAndSettle();

      // Verifica que aparece el nombre del alimento
      expect(find.text('Test Food'), findsOneWidget);
    });

    testWidgets('shows SnackBar when tapping add icon', (WidgetTester tester) async {
      final notifier = FakeNutritionNotifier();
      notifier.state = notifier.state.copyWith(
        foods: [
          Food(
            id: '1',
            externalId: 'ext1',
            name: 'Food',
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [nutritionProvider.overrideWith((ref) => notifier)],
          child: const MaterialApp(home: NutritionScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Pulsa el botón de añadir consumo
      final addBtn = find.widgetWithIcon(IconButton, Icons.add);
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Comprueba el SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Consumo registrado'), findsOneWidget);
    });
  });
}

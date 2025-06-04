// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:flutter_app/providers/auth_provider.dart';
// import 'package:flutter_app/screens/login_screen.dart';

// class FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
//   FakeAuthNotifier() : super(AuthState());

//   @override
//   Future<void> login(String email, String password) async {
//     state = state.copyWith(loading: true);
//     await Future.delayed(const Duration(milliseconds: 100));
//     state = state.copyWith(loading: false, token: 'fake-token');
//   }

//   @override
//   Future<void> register(String email, String password) async {
//     state = state.copyWith(loading: true);
//     await Future.delayed(const Duration(milliseconds: 100));
//     state = state.copyWith(loading: false, token: 'fake-token');
//   }

//   @override
//   Future<void> logout() async {
//     await Future.delayed(const Duration(milliseconds: 100));
//     state = AuthState();
//   }

//   @override
//   Future<void> fetchMe() async {
//     await Future.delayed(const Duration(milliseconds: 100));
//     state = state.copyWith(token: 'fake-token');
//   }

//   @override
//   Future<void> loadUser() async {
//     // Fake implementation for testing
//     await Future.delayed(const Duration(milliseconds: 100));
//     state = state.copyWith(token: 'fake-token');
//   }
// }

// void main() {
//   group('LoginScreen Widget Tests', () {
//     testWidgets('renders email & password fields and buttons',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             // Si es StateNotifierProvider, mejor usar overrideWithValue:
//             // authProvider.overrideWithValue(FakeAuthNotifier()),
//             authProvider.overrideWith((_) => FakeAuthNotifier()),
//           ],
//           child: const MaterialApp(home: LoginScreen()),
//         ),
//       );

//       // Verifica que los campos de texto y botones están presentes
//       expect(find.byType(TextField), findsNWidgets(2));
//       expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
//       expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
//     });

//     testWidgets('shows loading indicator when loading is true',
//         (WidgetTester tester) async {
//       final loadingNotifier = FakeAuthNotifier();
//       loadingNotifier.state = loadingNotifier.state.copyWith(loading: true);

//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             authProvider.overrideWith((_) => loadingNotifier),
//           ],
//           child: const MaterialApp(home: LoginScreen()),
//         ),
//       );

//       expect(find.byType(CircularProgressIndicator), findsOneWidget);
//     });

//     testWidgets('navigates to /home when login completes',
//         (WidgetTester tester) async {
//       final notifier = FakeAuthNotifier();

//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             authProvider.overrideWith((_) => notifier),
//           ],
//           child: MaterialApp(
//             initialRoute: '/',
//             routes: {
//               '/': (_) => const LoginScreen(),
//               '/home': (_) => const Scaffold(body: Text('Home')),
//             },
//           ),
//         ),
//       );

//       // Rellena campos
//       await tester.enterText(find.byType(TextField).first, 'test@x.com');
//       await tester.enterText(find.byType(TextField).last, 'password123');

//       // Pulsa Login
//       await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
//       await tester.pump(); // inicia el Future
//       await tester.pump(const Duration(milliseconds: 100)); // espera el delay
//       await tester.pumpAndSettle(); // procesa la navegación

//       expect(find.text('Home'), findsOneWidget);
//     });
//   });
// }

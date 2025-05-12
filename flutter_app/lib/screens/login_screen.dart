// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Lanza la acción de login
    await ref.read(authProvider.notifier).login(email, password);

    // Si este State ya no está montado, abortamos
    if (!mounted) return;

    final state = ref.read(authProvider);
    if (state.token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Lanza la acción de register
    await ref.read(authProvider.notifier).register(email, password);

    // Comprueba de nuevo el mounted
    if (!mounted) return;

    final state = ref.read(authProvider);
    if (state.token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Spinner de carga
            if (authState.loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
            ],

            // Mensaje de error
            if (authState.error != null) ...[
              Text(
                authState.error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
            ],

            // Botones Login / Register
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: authState.loading ? null : _login,
                  child: const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: authState.loading ? null : _register,
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

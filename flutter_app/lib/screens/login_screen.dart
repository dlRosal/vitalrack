import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  double _loginScale = 1.0;
  double _registerScale = 1.0;

  double _formOpacity = 0;
  Offset _formOffset = const Offset(0, 0.1);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _formOpacity = 1;
        _formOffset = Offset.zero;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    await ref.read(authProvider.notifier).login(email, password);
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    await ref.read(authProvider.notifier).register(email, password);
    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  InputDecoration _inputDecoration(String label, bool isFocused) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0F1A),
                  Color(0xFF0C141F),
                  Color(0xFF101A2B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logosinfondo.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    opacity: _formOpacity,
                    duration: const Duration(milliseconds: 800),
                    child: AnimatedSlide(
                      offset: _formOffset,
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24, width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.15),
                              Colors.green.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Bienvenido',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Focus(
                              child: Builder(builder: (context) {
                                final hasFocus = Focus.of(context).hasFocus;
                                return TextField(
                                  controller: _emailController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration:
                                      _inputDecoration('Email', hasFocus),
                                  keyboardType: TextInputType.emailAddress,
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            Focus(
                              child: Builder(builder: (context) {
                                final hasFocus = Focus.of(context).hasFocus;
                                return TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration:
                                      _inputDecoration('Contraseña', hasFocus),
                                );
                              }),
                            ),
                            const SizedBox(height: 20),
                            if (authState.loading) ...[
                              const CircularProgressIndicator(color: Colors.white),
                              const SizedBox(height: 20),
                            ],
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: authState.error != null
                                  ? Text(
                                      authState.error!,
                                      key: ValueKey(authState.error),
                                      style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    )
                                  : const SizedBox.shrink(key: ValueKey('no-error')),
                            ),
                            if (authState.error != null)
                              const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _loginScale = 0.95),
                                    onTapUp: (_) async {
                                      setState(() => _loginScale = 1.0);
                                      if (!authState.loading) await _login();
                                    },
                                    onTapCancel: () =>
                                        setState(() => _loginScale = 1.0),
                                    child: AnimatedScale(
                                      scale: _loginScale,
                                      duration: const Duration(milliseconds: 100),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2F855A),
                                              Color(0xFF38A169),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.greenAccent
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Iniciar Sesión',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _registerScale = 0.95),
                                    onTapUp: (_) async {
                                      setState(() => _registerScale = 1.0);
                                      if (!authState.loading) await _register();
                                    },
                                    onTapCancel: () =>
                                        setState(() => _registerScale = 1.0),
                                    child: AnimatedScale(
                                      scale: _registerScale,
                                      duration: const Duration(milliseconds: 100),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2B6CB0),
                                              Color(0xFF3182CE),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blueAccent
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Registrarse',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

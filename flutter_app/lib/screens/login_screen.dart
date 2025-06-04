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
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isFocused ? Colors.blueAccent : Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isFocused ? Colors.blueAccent : Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20), // reducido de 40 a 20
        child: Column(
          children: [
            const SizedBox(height: 20), // reducido de 40 a 20
            Image.asset(
              'assets/logosinfondo.png',
              height: 180,
            ),
            const SizedBox(height: 12), // reducido de 16 a 12

            AnimatedOpacity(
              opacity: _formOpacity,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: AnimatedSlide(
                offset: _formOffset,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Iniciar Sesión | Registrarse',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Focus(
                            child: Builder(builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return TextField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Email', hasFocus),
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
                                decoration: _inputDecoration('Contraseña', hasFocus),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          if (authState.loading) ...[
                            const Center(child: CircularProgressIndicator(color: Colors.white)),
                            const SizedBox(height: 20),
                          ],

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: authState.error != null
                                ? Text(
                                    authState.error!,
                                    key: ValueKey(authState.error),
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  )
                                : const SizedBox.shrink(key: ValueKey('no-error')),
                          ),

                          if (authState.error != null) const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTapDown: (_) => setState(() => _loginScale = 0.95),
                                  onTapUp: (_) async {
                                    setState(() => _loginScale = 1.0);
                                    if (!authState.loading) await _login();
                                  },
                                  onTapCancel: () => setState(() => _loginScale = 1.0),
                                  child: AnimatedScale(
                                    scale: _loginScale,
                                    duration: const Duration(milliseconds: 100),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _loginScale < 1.0
                                            ? Colors.green[700]
                                            : const Color(0xFF2F855A),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.greenAccent.withOpacity(
                                                _loginScale < 1.0 ? 0.6 : 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Iniciar Sesión',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            letterSpacing: 1.1,
                                            color: Colors.white,
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
                                  onTapDown: (_) => setState(() => _registerScale = 0.95),
                                  onTapUp: (_) async {
                                    setState(() => _registerScale = 1.0);
                                    if (!authState.loading) await _register();
                                  },
                                  onTapCancel: () => setState(() => _registerScale = 1.0),
                                  child: AnimatedScale(
                                    scale: _registerScale,
                                    duration: const Duration(milliseconds: 100),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _registerScale < 1.0
                                            ? Colors.blue[700]
                                            : const Color(0xFF2C5282),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blueAccent.withOpacity(
                                                _registerScale < 1.0 ? 0.6 : 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Registrarse',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            letterSpacing: 1.1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

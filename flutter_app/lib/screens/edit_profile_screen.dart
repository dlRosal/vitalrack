// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final User initialUser;

  const EditProfileScreen({Key? key, required this.initialUser}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _usernameController;
  String? _selectedGender;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  bool _isSubmitting = false;
  String? _errorMessage;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    final u = widget.initialUser;
    _usernameController = TextEditingController(text: u.username);

    if (u.gender == 'Hombre' || u.gender == 'Mujer') {
      _selectedGender = u.gender;
    } else {
      _selectedGender = null;
    }

    _ageController = TextEditingController(text: u.age?.toString() ?? '');
    _heightController = TextEditingController(text: u.height?.toString() ?? '');
    _weightController = TextEditingController(text: u.weight?.toString() ?? '');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final token = ref.read(authProvider).token;
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final username = _usernameController.text.trim();
      final gender = _selectedGender;
      final age = _ageController.text.trim().isEmpty
          ? null
          : int.tryParse(_ageController.text.trim());
      final height = _heightController.text.trim().isEmpty
          ? null
          : double.tryParse(_heightController.text.trim());
      final weight = _weightController.text.trim().isEmpty
          ? null
          : double.tryParse(_weightController.text.trim());

      final authService = ref.read(authServiceProvider);
      final updatedUser = await authService.updateProfile(
        token: token,
        username: username,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
      );

      if (!mounted) return;
      Navigator.pop(context, updatedUser);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget animatedField(Widget child, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedPadding(
        duration: Duration(milliseconds: 300 + index * 100),
        padding: const EdgeInsets.only(bottom: 12),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  animatedField(
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    0,
                  ),
                  animatedField(
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Género',
                        prefixIcon: Icon(Icons.wc),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Hombre', child: Text('Hombre')),
                        DropdownMenuItem(value: 'Mujer', child: Text('Mujer')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedGender = val;
                        });
                      },
                    ),
                    1,
                  ),
                  animatedField(
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: Icon(Icons.cake),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 30',
                      ),
                    ),
                    2,
                  ),
                  animatedField(
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Altura (cm)',
                        prefixIcon: Icon(Icons.height),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 175',
                      ),
                    ),
                    3,
                  ),
                  animatedField(
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        prefixIcon: Icon(Icons.fitness_center),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 72.5',
                      ),
                    ),
                    4,
                  ),
                  const SizedBox(height: 20),

                  if (_errorMessage != null)
                    animatedField(
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      5,
                    ),

                  ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0)
                        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _genderController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final u = widget.initialUser;
    _usernameController = TextEditingController(text: u.username);
    _genderController = TextEditingController(text: u.gender ?? '');
    _ageController = TextEditingController(text: u.age?.toString() ?? '');
    _heightController = TextEditingController(text: u.height?.toString() ?? '');
    _weightController = TextEditingController(text: u.weight?.toString() ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _genderController.dispose();
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
      // Si no hay token, forzamos logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final username = _usernameController.text.trim();
      final gender = _genderController.text.trim().isEmpty
          ? null
          : _genderController.text.trim();
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

      // Al regresar, devolvemos el User actualizado
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de usuario',
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _genderController,
              decoration: const InputDecoration(
                labelText: 'Género',
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(),
                hintText: 'Ej: Hombre, Mujer, Otro...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Edad',
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(),
                hintText: 'Ej: 30',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Altura (cm)',
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(),
                hintText: 'Ej: 175',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(),
                hintText: 'Ej: 72.5',
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
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
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Guardar cambios',
                      style:
                          TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

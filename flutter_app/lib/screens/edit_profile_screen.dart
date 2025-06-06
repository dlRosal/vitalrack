import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final User initialUser;

  const EditProfileScreen({Key? key, required this.initialUser})
      : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _usernameController;
  String? _selectedGender;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGoal;
  int? _trainingDays;

  bool _isSubmitting = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final u = widget.initialUser;

    _usernameController = TextEditingController(text: u.username);
    _selectedGender = (u.gender == 'male' || u.gender == 'female') ? u.gender : null;
    _ageController = TextEditingController(text: u.age?.toString() ?? '');
    _heightController = TextEditingController(text: u.height?.toString() ?? '');
    _weightController = TextEditingController(text: u.weight?.toString() ?? '');
    _selectedGoal = u.goal;
    _trainingDays = u.trainingDays;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
      final goal = _selectedGoal;
      final trainingDays = _trainingDays;

      final authService = ref.read(authServiceProvider);
      final updatedUser = await authService.updateProfile(
        token: token,
        username: username,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        goal: goal,
        trainingDays: trainingDays,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return AnimatedOpacity(
                opacity: _animController.value,
                duration: const Duration(milliseconds: 300),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildTextField(_usernameController, 'Nombre de usuario', Icons.person),
                  const SizedBox(height: 12),
                  _buildDropdownGender(),
                  const SizedBox(height: 12),
                  _buildTextField(_ageController, 'Edad', Icons.cake, isNumber: true, hint: 'Ej: 30'),
                  const SizedBox(height: 12),
                  _buildTextField(_heightController, 'Altura (cm)', Icons.height, isNumber: true, hint: 'Ej: 175'),
                  const SizedBox(height: 12),
                  _buildTextField(_weightController, 'Peso (kg)', Icons.fitness_center, isNumber: true, hint: 'Ej: 72.5'),
                  const SizedBox(height: 12),
                  _buildDropdownGoal(),
                  const SizedBox(height: 12),
                  _buildDropdownTrainingDays(),
                  const SizedBox(height: 20),
                  if (_errorMessage != null) ...[
                    AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, String? hint}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdownGender() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Género',
        prefixIcon: Icon(Icons.wc),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('Hombre')),
        DropdownMenuItem(value: 'female', child: Text('Mujer')),
        DropdownMenuItem(value: 'other', child: Text('Otro')),
      ],
      onChanged: (val) {
        setState(() {
          _selectedGender = val;
        });
      },
    );
  }

  Widget _buildDropdownGoal() {
    return DropdownButtonFormField<String>(
      value: _selectedGoal,
      decoration: const InputDecoration(
        labelText: 'Objetivo',
        prefixIcon: Icon(Icons.flag),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'bulk', child: Text('Ganar volumen')),
        DropdownMenuItem(value: 'cut', child: Text('Definir')),
        DropdownMenuItem(value: 'maintain', child: Text('Mantener')),
      ],
      onChanged: (val) {
        setState(() {
          _selectedGoal = val;
        });
      },
    );
  }

  Widget _buildDropdownTrainingDays() {
    return DropdownButtonFormField<int>(
      value: _trainingDays,
      decoration: const InputDecoration(
        labelText: 'Días de entrenamiento/semana',
        prefixIcon: Icon(Icons.calendar_today),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(),
      ),
      items: List.generate(
        7,
        (i) => DropdownMenuItem(
          value: i + 1,
          child: Text('${i + 1}'),
        ),
      ),
      onChanged: (val) {
        setState(() {
          _trainingDays = val;
        });
      },
    );
  }
}

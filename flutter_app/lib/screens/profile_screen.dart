// lib/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      _controller.forward(from: 0.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String generoLegible(String? gender) {
    if (gender == 'male') return 'Hombre';
    if (gender == 'female') return 'Mujer';
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLoading = authState.loading;
    final token = authState.token;

    if (token == null || user == null) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.tealAccent),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.tealAccent))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: ListView(
                      key: ValueKey(user), // Para asegurar que AnimatedSwitcher funcione
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.tealAccent.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFF263238),
                                backgroundImage: _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                    : null,
                                child: _pickedImage == null
                                    ? Text(
                                        user.username.isNotEmpty
                                            ? user.username[0].toUpperCase()
                                            : user.email[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 40,
                                          color: Colors.tealAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
                              _buildInfoTile('Usuario',
                                  user.username.isNotEmpty ? user.username : '—'),
                              _buildInfoTile('Correo electrónico', user.email),
                              _buildInfoTile(
                                  'Género', generoLegible(user.gender) ?? '—'),
                              _buildInfoTile('Edad',
                                  user.age != null ? '${user.age} años' : '—'),
                              _buildInfoTile('Altura',
                                  user.height != null ? '${user.height} cm' : '—'),
                              _buildInfoTile('Peso',
                                  user.weight != null ? '${user.weight} kg' : '—'),
                              _buildInfoTile(
                                'Objetivo',
                                user.goal == 'bulk'
                                    ? 'Ganar volumen'
                                    : user.goal == 'cut'
                                        ? 'Definir'
                                        : 'Mantener',
                              ),
                              _buildInfoTile(
                                'Días de entrenamiento',
                                user.trainingDays?.toString() ?? '—',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          label: const Text(
                            'Editar Perfil',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: Colors.tealAccent.withOpacity(0.6),
                          ),
                          onPressed: () async {
                            final updatedUser = await Navigator.push<User>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProfileScreen(initialUser: user),
                              ),
                            );
                            if (updatedUser != null) {
                              await ref.read(authProvider.notifier).loadUser();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
        border: Border.all(
          color: Colors.tealAccent.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.tealAccent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

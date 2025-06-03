// flutter_app/lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLoading = authState.loading;
    final token = authState.token;

    // Si no hay token (o user es null), redirige al login inmediatamente:
    if (token == null || user == null) {
      // NOTA: para redirigir sin renderizar nada antes, usamos Future.microtask:
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      // si tu backend no tiene “username”, puedes usar primera letra de email:
                      user.name != null && user.name!.isNotEmpty
                          ? user.name![0].toUpperCase()
                          : user.email[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                    'Usuario',
                    user.name != null && user.name!.isNotEmpty
                        ? user.name!
                        : '—',
                  ),
                  _buildInfoTile('Correo electrónico', user.email),
                  _buildInfoTile('Género', user.gender ?? '—'),
                  _buildInfoTile(
                    'Edad',
                    user.age != null ? '${user.age} años' : '—',
                  ),
                  _buildInfoTile(
                    'Altura',
                    user.height != null ? '${user.height} cm' : '—',
                  ),
                  _buildInfoTile(
                    'Peso',
                    user.weight != null ? '${user.weight} kg' : '—',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Perfil'),
                    onPressed: () {
                      // Opcional: navegar a pantalla de edición de perfil
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }
}

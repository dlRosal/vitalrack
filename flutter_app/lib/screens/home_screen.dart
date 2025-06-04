import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _hoveredOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vitalrack',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: 'Ver perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: Image.asset('assets/logosinfondo.png'),
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 40),
              _buildOptionCard(
                context,
                title: 'Nutrición',
                icon: Icons.restaurant_menu_rounded,
                color: const Color(0xFF2F855A),
                route: '/nutrition',
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                title: 'Entrenamiento',
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFF2C5282),
                route: '/training',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    final isHovered = _hoveredOption == title;
    final borderColor = color.withOpacity(0.6);
    final iconColor = color;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredOption = title),
      onExit: (_) => setState(() => _hoveredOption = null),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: isHovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            color: Color.lerp(const Color(0xFF1E1E1E), color.withOpacity(0.12), isHovered ? 1 : 0),
            borderRadius: BorderRadius.circular(20),
            gradient: isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.10),
                      color.withOpacity(0.05),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E1E1E),
                      const Color(0xFF1C1C1C),
                      color.withOpacity(0.05),
                    ],
                  ),
            border: Border.all(
              color: borderColor.withOpacity(isHovered ? 0.8 : 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.8 : 0.6),
                blurRadius: isHovered ? 28 : 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: color.withOpacity(isHovered ? 0.3 : 0.15),
                blurRadius: isHovered ? 40 : 30,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: color.withOpacity(0.3),
            highlightColor: color.withOpacity(0.15),
            onTap: () => Navigator.pushNamed(context, route),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 36, color: iconColor),
                ),
                const SizedBox(width: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

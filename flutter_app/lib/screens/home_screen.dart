import 'dart:math';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? _hoveredOption;
  bool _isProfileHovered = false;
  late AnimationController _fadeController;
  late AnimationController _bgParticlesController;
  late Animation<double> _fadeAnimation;

  final int _particleCount = 80;
  final Random _random = Random();

  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    _bgParticlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _particles = List.generate(_particleCount, (index) {
      return _Particle(
        dx: _random.nextDouble(),
        dy: _random.nextDouble(),
        radius: _random.nextDouble() * 2.5 + 0.5,
        speedX: _random.nextDouble() * 0.001 - 0.0005,
        speedY: _random.nextDouble() * 0.001 - 0.0005,
        opacity: _random.nextDouble() * 0.5 + 0.2,
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bgParticlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Fondo animado de partículas
          AnimatedBuilder(
            animation: _bgParticlesController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(particles: _particles, progress: _bgParticlesController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Contenido con fade
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo con glow animado
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(CurvedAnimation(parent: _bgParticlesController, curve: Curves.linear)),
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.blueAccent.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.4, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: Image.asset('assets/logosinfondo.png'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildOptionCard(
                          context,
                          title: 'Nutrición',
                          icon: Icons.restaurant_menu_rounded,
                          color: const Color(0xFF2F855A),
                          route: '/nutrition',
                        ),
                        const SizedBox(height: 28),
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
              ),
            ),
          ),

          // AppBar personalizado
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
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
                MouseRegion(
                  onEnter: (_) => setState(() => _isProfileHovered = true),
                  onExit: (_) => setState(() => _isProfileHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: AnimatedScale(
                    scale: _isProfileHovered ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isProfileHovered ? Colors.white.withOpacity(0.12) : Colors.transparent,
                        boxShadow: _isProfileHovered
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.person_outline),
                        color: Colors.white,
                        tooltip: 'Ver perfil',
                        iconSize: 42,
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        splashRadius: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        scale: isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E1E1E),
                      const Color(0xFF1C1C1C),
                      color.withOpacity(0.04),
                    ],
                  ),
            border: Border.all(
              color: borderColor.withOpacity(isHovered ? 0.8 : 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.8 : 0.6),
                blurRadius: isHovered ? 30 : 22,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: color.withOpacity(isHovered ? 0.35 : 0.2),
                blurRadius: isHovered ? 45 : 35,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            splashColor: color.withOpacity(0.3),
            highlightColor: color.withOpacity(0.15),
            onTap: () => Navigator.pushNamed(context, route),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 40, color: iconColor),
                ),
                const SizedBox(width: 28),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  double dx, dy, radius, speedX, speedY, opacity;
  _Particle({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });

  void update(double progress) {
    dx += speedX;
    dy += speedY;

    if (dx < 0 || dx > 1) speedX = -speedX;
    if (dy < 0 || dy > 1) speedY = -speedY;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress}) {
    for (var p in particles) {
      p.update(progress);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var p in particles) {
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.dx * size.width, p.dy * size.height), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

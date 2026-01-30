import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'dart:math';

class AuraOrb extends StatefulWidget {
  final double size;
  const AuraOrb({super.key, this.size = 200});

  @override
  State<AuraOrb> createState() => _AuraOrbState();
}

class _AuraOrbState extends State<AuraOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Positions fixes pour les étoiles
  final List<Point<double>> _stars = List.generate(12, (_) {
    final r = sqrt(Random().nextDouble()) * 0.7; // Rayon max 0.7
    final theta = Random().nextDouble() * 2 * pi;
    return Point(r * cos(theta), r * sin(theta)); 
  });

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Le dégradé original de l'orbe "Bioluminescent"
            gradient: RadialGradient(
              colors: [
                AuraColors.electricCyan.withOpacity(0.9), 
                AuraColors.electricCyan.withOpacity(0.6),
                AuraColors.deepSpaceBlue, 
              ],
              stops: const [0.3, 0.7, 1.0],
            ),
            boxShadow: [
              // Glow externe respirant
              BoxShadow(
                color: AuraColors.electricCyan.withOpacity(0.6),
                blurRadius: 20 + (30 * _controller.value),
                spreadRadius: 2 + (10 * _controller.value),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _StarsPainter(_stars, _controller.value),
          ),
        );
      },
    );
  }
}

class _StarsPainter extends CustomPainter {
  final List<Point<double>> stars;
  final double animationValue;

  _StarsPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < stars.length; i++) {
      final star = stars[i];
      // Scintillement des étoiles
      // On utilise i pour déphaser le scintillement
      double twinkle = sin((animationValue * 2 * pi) + i); 
      double opacity = 0.5 + (0.5 * twinkle); 
      
      paint.color = Colors.white.withOpacity(opacity.clamp(0.2, 1.0));
      
      canvas.drawCircle(
        Offset(center.dx + (star.x * radius), center.dy + (star.y * radius)),
        2.0 + (1.0 * animationValue), // Légère variation de taille
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

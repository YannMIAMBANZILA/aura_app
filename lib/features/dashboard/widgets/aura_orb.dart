import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';

class AuraOrb extends StatefulWidget {
  final double size;
  const AuraOrb({super.key, this.size = 200});

  @override
  State<AuraOrb> createState() => _AuraOrbState();
}

class _AuraOrbState extends State<AuraOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation de "respiration" infinie (2 secondes)
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
              // Création de l'orbe en code pour garantir qu'il occupe toute la surface
              gradient: RadialGradient(
                colors: [
                  AuraColors.electricCyan.withOpacity(0.9), // Coeur lumineux
                  AuraColors.electricCyan.withOpacity(0.6),
                  const Color(0xFF0F172A), // Fondu vers le bord (DeepSpaceBlue)
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
              boxShadow: [
                // Glow externe qui respire
                BoxShadow(
                  color: AuraColors.electricCyan.withOpacity(0.6),
                  blurRadius: 20 + (30 * _controller.value),
                  spreadRadius: 2 + (10 * _controller.value),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20), // Un peu de padding pour que le cerveau ne touche pas les bords
            child: Center(
              child: Image.asset(
                'assets/images/brain_shape_dark.png',
                fit: BoxFit.contain,
              ),
            ),
          );
      },
    );
  }
}
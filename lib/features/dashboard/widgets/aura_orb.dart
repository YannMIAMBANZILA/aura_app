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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AuraColors.electricCyan,
                AuraColors.mintNeon,
              ],
            ),
            boxShadow: [
              // Couche externe (Glow diffus) - Elle respire avec l'animation
              BoxShadow(
                color: AuraColors.electricCyan.withOpacity(0.6),
                blurRadius: 40 + (20 * _controller.value), // Rayon variable
                spreadRadius: 10 * _controller.value,      // Étale variable
              ),
              // Couche interne (Cœur blanc intense)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 20,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Center(
            // Ici on mettra plus tard le logo cerveau en SVG
            child: Icon(
              Icons.auto_awesome, 
              color: Colors.white, 
              size: widget.size * 0.4
            ),
          ),
        );
      },
    );
  }
}
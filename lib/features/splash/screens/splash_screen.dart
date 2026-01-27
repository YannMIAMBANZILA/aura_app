import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:aura_app/features/auth/screens/login_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _fadeController;
  
  @override
  void initState() {
    super.initState();
    
    // Contrôleur pour l'animation des ondes (ripples)
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Toujours actif, ou on peut le synchroniser

    // Contrôleur pour la séquence de fin (fondu texte -> navigation)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // 1. Délai initial
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 2. Lancer le fading
    await _fadeController.forward();

    // 3. Navigation
    if (!mounted) return;
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 1000),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        ),
      );
    } else {
       Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 1000),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.deepSpaceBlue,
      body: Stack(
        children: [
          // 1. Fond avec effet d'ondes (Ripples)
          // Elles apparaissent progressivement ou sont là dès le début
          Positioned.fill(
            child: CustomPaint(
              painter: RipplePainter(
                animationValue: _rippleController,
              ),
            ),
          ),

          // 2. Texte AURA centré
          Center(
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(
                  parent: _fadeController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: Text(
                'AURA',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                  color: Colors.white70,
                  shadows: [
                    BoxShadow(
                      color: AuraColors.electricCyan.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: AuraColors.electricCyan.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final Animation<double> animationValue;

  RipplePainter({required this.animationValue}) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);

    // On dessine plusieurs cercles concentriques qui s'étendent
    for (int i = 0; i < 3; i++) {
      // Décalage pour chaque onde
      final double progress = (animationValue.value + (i / 3.0)) % 1.0;
      
      final Paint paint = Paint()
        ..color = AuraColors.electricCyan.withOpacity((1.0 - progress) * 0.3) // S'estompe vers l'extérieur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + (progress * 10); // S'épaissit légèrement

      final double radius = progress * maxRadius * 0.8;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

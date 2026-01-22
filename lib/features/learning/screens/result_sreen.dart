import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_app/config/theme.dart';
import 'package:confetti/confetti.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Durée courte mais intense
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Tentative de lancement automatique après 1 seconde
    if (widget.score > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) { // Vérifie si l'écran est toujours là
          _confettiController.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un Stack pour que les confettis soient AU-DESSUS de tout
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 1. Le contenu de l'écran (en dessous)
        Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    "SESSION TERMINÉE",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      color: AuraColors.electricCyan,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // LE CERCLE EST MAINTENANT CLIQUABLE (GestureDetector)
                  GestureDetector(
                    onTap: () {
                      // CLIQUE ICI POUR TESTER LES CONFETTIS !
                      _confettiController.play();
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AuraColors.electricCyan, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AuraColors.electricCyan.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "+${widget.score}",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: AuraColors.mintNeon,
                            ),
                          ),
                          Text(
                            "Points Aura",
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white70,
                            ),
                          ),
                          // Petit indice visuel
                           Padding(
                             padding: EdgeInsets.only(top: 8.0),
                             child: Icon(Icons.touch_app, color: Colors.white30, size: 20),
                           ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  Text(
                    "Questions : ${widget.totalQuestions}",
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const Spacer(),

                  // Bouton Retour
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraColors.electricCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "RETOUR AU DASHBOARD",
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        // 2. Le canon à confettis (Au-dessus)
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 30, // Plus de particules !
          gravity: 0.3, // Tombent un peu plus lentement
          colors: const [
            AuraColors.electricCyan,
            AuraColors.mintNeon,
            AuraColors.softCoral,
            Colors.white,
            Colors.amberAccent, // Ajout d'une couleur vive
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_app/config/theme.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../providers/user_provider.dart';
import '../../../services/notification_service.dart';


class ResultScreen extends ConsumerStatefulWidget {
  final int earnedPoints;
  final int streak;
  final int endingScore; // Score total APRES la session
  final String? earnedBadge; // Nouveau badge gagné

  const ResultScreen({
    super.key,
    required this.earnedPoints,
    required this.streak,
    required this.endingScore,
    this.earnedBadge,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ConfettiController _confettiController;
  String? _rankUpMessage;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Jouer les confettis automatiquement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRankUp();
      _confettiController.play();
    });
  }

  Future<void> _checkRankUp() async {
    final oldScore = widget.endingScore - widget.earnedPoints;
    final userState = ref.read(userProvider); // UserState pour util methode
    
    // On doit reconstruire un objet UserState ou accéder à une méthode statique/utilitaire
    // Mais UserState a la logique getTitle.
    // Hack: on utilise l'instance actuelle du userProvider
    
    final oldTitle = ref.read(userProvider).getTitle(oldScore);
    final newTitle = ref.read(userProvider).getTitle(widget.endingScore);

    if (oldTitle != newTitle) {
      setState(() {
        _rankUpMessage = "Ton Aura a transcendé ! Tu es désormais $newTitle";
      });
      await NotificationService().showRankUpNotification(newTitle);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 1. Fond et Contenu
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

                  // 2. CERCLE FLAMME 🔥
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AuraColors.abyssalGrey,
                      border: Border.all(color: AuraColors.electricCyan, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AuraColors.electricCyan.withOpacity(0.4),
                          blurRadius: 50,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.whatshot, size: 80, color: AuraColors.electricCyan), // Cyan demandé
                        const SizedBox(height: 8),
                        Text(
                          "${widget.streak} Jours",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. CALCUL STYLISÉ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("50 pts", style: TextStyle(color: Colors.white70, fontSize: 18)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(Icons.close, color: AuraColors.mintNeon, size: 20),
                        ),
                        Text("${widget.streak}", style: const TextStyle(color: AuraColors.electricCyan, fontSize: 24, fontWeight: FontWeight.bold)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(Icons.arrow_right_alt, color: Colors.white54),
                        ),
                        Text(
                          "+${widget.earnedPoints}", 
                          style: GoogleFonts.spaceGrotesk(color: AuraColors.mintNeon, fontSize: 32, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 4. MESSAGE LAURA (Si Rank Up)
                  if (_rankUpMessage != null)
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AuraColors.electricCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AuraColors.electricCyan.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AuraColors.electricCyan),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _rankUpMessage!,
                                style: const TextStyle(color: AuraColors.electricCyan, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 4.1 MESSAGE BADGE (Si Badge gagné)
                  if (widget.earnedBadge != null)
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AuraColors.mintNeon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AuraColors.mintNeon.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: AuraColors.mintNeon),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Nouveau Sceau débloqué : ${widget.earnedBadge} !",
                                style: const TextStyle(color: AuraColors.mintNeon, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const Spacer(),

                  // 5. BOUTON RETOUR
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraColors.electricCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      onPressed: () {
                         // Réinitialise tout en rechargeant le Dashboard
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "RETOUR AU DOSSIER",
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        // 6. CONFETTI
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 50,
          colors: const [
            AuraColors.electricCyan,
            AuraColors.mintNeon,
            Colors.white,
            Colors.amber,
          ],
        ),
      ],
    );
  }
}
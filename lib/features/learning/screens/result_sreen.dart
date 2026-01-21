import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/widgets/aura_orb.dart'; // On réutilise notre Orbe !
import '../../../providers/user_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState(); // On ajoute les points dès que l'écran est chargé
    // On utilise Future.microtask pour ne pas bloquer l'UI
    Future.microtask(() {
    ref.read(auraProvider.notifier).addPoints(widget.score);
  });
  }


  @override
  Widget build(BuildContext context) {
    // Calcul du pourcentage de réussite
    final percentage = (widget.score / widget.totalQuestions) * 100;
    String title = "Session Validée";
    String subtitle = "Ton Aura se stabilise.";
    Color glowColor = AuraColors.electricCyan;

    // Petit message personnalisé selon le score
    if (percentage == 100) {
      title = "AURA MAXIMALE !";
      subtitle = "Incroyable. Aucune erreur.";
      glowColor = AuraColors.mintNeon; // Vert intense
    } else if (percentage < 50) {
      title = "Entraînement Terminé";
      subtitle = "C'est en forgeant qu'on devient forgeron.";
      glowColor = AuraColors.softCoral; // Un peu rouge/orange
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // 1. L'Orbe de Victoire (Plus grand)
              Stack(
                alignment: Alignment.center,
                children: [
                  AuraOrb(size: 250), // Notre widget existant
                  Text(
                    "+${widget.score}", // Le score au centre
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: glowColor, blurRadius: 20),
                      ]
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // 2. Textes de félicitations
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: glowColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Spacer(),

              // 3. Bouton Retour Dashboard
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // On revient à l'accueil en retirant tous les écrans précédents
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.starlightWhite.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("RETOUR À L'ACCUEIL"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
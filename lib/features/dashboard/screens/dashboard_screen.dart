import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart'; // Vérifie bien le chemin d'import
import 'package:google_fonts/google_fonts.dart';
import '../widgets/aura_orb.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Titre
              Text(
                "TON AURA",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 60),

              // 2. L'Orbe au centre
              const AuraOrb(size: 180),

              const SizedBox(height: 60),

              // 3. Texte d'encouragement
              Text(
                "Prêt à briller ?",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "6 minutes pour faire la différence.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 48),

              // 4. Bouton d'Action (Style Néon)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Action future : Lancer session
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.electricCyan.withOpacity(0.1),
                    shadowColor: AuraColors.electricCyan,
                    elevation: 10,
                    side: const BorderSide(color: AuraColors.electricCyan, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "LANCER UNE SESSION",
                    style: GoogleFonts.spaceGrotesk(
                      color: AuraColors.electricCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
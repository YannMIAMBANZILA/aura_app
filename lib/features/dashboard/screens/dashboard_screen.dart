import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../widgets/aura_orb.dart';
import '../../learning/screens/session_screen.dart';
import '../../../providers/user_provider.dart';
import '../../auth/screens/login_screen.dart'; 

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentAura = ref.watch(auraProvider);
    // On vérifie si l'utilisateur est connecté
    final user = Supabase.instance.client.auth.currentUser;
    final isGuest = user == null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. HEADER AVEC ICONE PROFIL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icone invisible juste pour centrer le titre
                  const SizedBox(width: 40), 
                  
                  // TITRE
                  Text(
                    "TON AURA",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  // BOUTON PROFIL / CONNEXION
                  IconButton(
                    onPressed: () {
                      if (isGuest) {
                        // Si invité -> On va vers le Login
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const LoginScreen())
                        );
                      } else {
                        // Si connecté -> On propose de se déconnecter (ou voir profil)
                        _showLogoutDialog(context);
                      }
                    },
                    icon: Icon(
                      isGuest ? Icons.login : Icons.account_circle,
                      color: isGuest ? AuraColors.softCoral : AuraColors.electricCyan,
                    ),
                    tooltip: isGuest ? "Se connecter" : "Mon Compte",
                  ),
                ],
              ),

              const Spacer(), // Pousse le contenu vers le centre

              // --- LE SCORE ---
              Text(
                "$currentAura",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AuraColors.electricCyan,
                  shadows: [
                    Shadow(
                      color: AuraColors.electricCyan.withOpacity(0.8),
                      blurRadius: 30,
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 60),

              const AuraOrb(size: 180),

              const SizedBox(height: 60),

              // Textes...
              Text(
                isGuest ? "Mode Invité" : "Prêt à briller ?", // Petit clin d'oeil
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                "6 minutes pour faire la différence.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Spacer(), // Pousse le bouton vers le bas

              // BOUTON Lancer
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.electricCyan.withOpacity(0.1),
                    shadowColor: AuraColors.electricCyan,
                    elevation: 10,
                    side: const BorderSide(color: AuraColors.electricCyan, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SessionScreen()));
                  },
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Petite popup pour se déconnecter
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuraColors.abyssalGrey,
        title: const Text("Compte", style: TextStyle(color: Colors.white)),
        content: const Text("Veux-tu te déconnecter ?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                // On recharge l'écran pour mettre à jour l'icône
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
              }
            },
            child: const Text("Se déconnecter", style: TextStyle(color: AuraColors.softCoral)),
          ),
        ],
      ),
    );
  }
}
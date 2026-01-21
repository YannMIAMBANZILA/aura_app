import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/aura_orb.dart';
import '../../learning/screens/session_screen.dart';
import '../../../providers/user_provider.dart';
import '../../auth/screens/login_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _username; // Pour stocker le pseudo
  bool _isGuest = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() => _isGuest = false);
      // On récupère le pseudo depuis la table profiles
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('username')
            .eq('id', user.id)
            .single();
        
        if (mounted && data['username'] != null) {
          setState(() {
            _username = data['username'];
          });
        }
      } catch (e) {
        // En cas d'erreur (hors ligne), on garde l'affichage par défaut
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentAura = ref.watch(auraProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. HEADER PERSONNALISÉ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Équilibre visuel
                  
                  // TITRE DYNAMIQUE
                  Column(
                    children: [
                      Text(
                        _username != null ? "TON AURA ${_username!.toUpperCase()}" : "TON AURA",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                          color: _isGuest ? Colors.white70 : AuraColors.electricCyan, // Cyan si connecté
                        ),
                      ),
                      if (_isGuest)
                        Text(
                          "(Invité)",
                          style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AuraColors.softCoral),
                        )
                    ],
                  ),

                  // BOUTON PROFIL
                  IconButton(
                    onPressed: () {
                      if (_isGuest) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      } else {
                        _showLogoutDialog(context);
                      }
                    },
                    icon: Icon(
                      _isGuest ? Icons.login : Icons.account_circle,
                      color: _isGuest ? AuraColors.softCoral : AuraColors.electricCyan,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // LE SCORE
              Text(
                "$currentAura",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AuraColors.electricCyan,
                  shadows: [
                    Shadow(color: AuraColors.electricCyan.withOpacity(0.8), blurRadius: 30)
                  ],
                ),
              ),
              
              const SizedBox(height: 60),

              const AuraOrb(size: 180),

              const SizedBox(height: 60),

              Text(
                _isGuest ? "Mode Invité" : "Prêt à briller, $_username ?",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                "6 minutes pour faire la différence.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Spacer(),

              // BOUTON LANCER
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.electricCyan.withOpacity(0.1),
                    shadowColor: AuraColors.electricCyan,
                    elevation: 10,
                    side: const BorderSide(color: AuraColors.electricCyan, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionScreen()));
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuraColors.abyssalGrey,
        title: const Text("Compte", style: TextStyle(color: Colors.white)),
        content: Text("Au revoir $_username, veux-tu te déconnecter ?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pop(context);
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
import 'package:aura_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_app/config/theme.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // 1. Fonction de Connexion (Login)
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await ref.read(auraProvider.notifier).syncLocalToCloud();

      if (mounted) {
        // Redirection vers le Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Erreur inattendue");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // 2. Fonction d'Inscription (Sign Up)
  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await ref.read(auraProvider.notifier).syncLocalToCloud();

      _showSuccess("Compte créé ! Tu es connecté.");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Erreur lors de l'inscription");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // Helpers pour afficher les messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AuraColors.softCoral),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AuraColors.mintNeon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "IDENTIFICATION",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  letterSpacing: 4, 
                  color: AuraColors.electricCyan
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Champ Email
              _buildTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              
              // Champ Mot de passe
              _buildTextField(
                controller: _passwordController,
                label: "Mot de passe",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              
              const SizedBox(height: 40),

              // Bouton SE CONNECTER
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AuraColors.electricCyan))
              else
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.electricCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("SE CONNECTER", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                ),

              const SizedBox(height: 16),

              // Bouton CRÉER UN COMPTE
              OutlinedButton(
                onPressed: _signUp,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AuraColors.starlightWhite),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("CRÉER UN COMPTE", style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 40),
              const Divider(color: Colors.white24),
              const SizedBox(height: 20),

              // Bouton GOOGLE (Visuel pour l'instant)
              OutlinedButton.icon(
                onPressed: () {
                  _showError("Configuration Google en cours...");
                  // On implémentera ça à l'étape suivante !
                },
                icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.white),
                label: const Text("Continuer avec Google", style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
              // ... après le bouton Google ...

const SizedBox(height: 24),

// BOUTON MODE INVITÉ
TextButton(
  onPressed: () {
    // On va directement au Dashboard sans s'authentifier
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  },
  child: Text(
    "Continuer sans compte (Mode Invité)",
    style: GoogleFonts.spaceGrotesk(
      color: Colors.white54,
      decoration: TextDecoration.underline,
      fontSize: 14,
    ),
  ),
),
            ],

          ),
        ),
      ),
    );
  }

  // Widget utilitaire pour le style des champs
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AuraColors.electricCyan),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AuraColors.electricCyan.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraColors.electricCyan),
        ),
        filled: true,
        fillColor: AuraColors.abyssalGrey,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_app/config/theme.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../providers/user_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  // Mode "Inscription" ou "Connexion"
  bool _isRegistering = false; 

  // 1. GESTION DE LA VALIDATION DU FORMULAIRE
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (_isRegistering) {
        await _signUp();
      } else {
        await _signIn();
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Une erreur est survenue : $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. LOGIQUE DE CONNEXION
  Future<void> _signIn() async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (mounted) {
      await ref.read(auraProvider.notifier).syncLocalToCloud();
      _goToDashboard();
    }
  }

  // 3. LOGIQUE D'INSCRIPTION (AVEC PSEUDO)
  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();

    // A. Inscription Auth
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: _passwordController.text.trim(),
    );

    // B. Mise à jour du Profil (Pseudo + Email)
    if (response.user != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'username': username, // On stocke le vrai pseudo
            'email': email,       // On stocke l'email dans sa colonne
          })
          .eq('id', response.user!.id);
    }

    // C. Synchro
    if (mounted) {
      await ref.read(auraProvider.notifier).syncLocalToCloud();
      _showSuccess("Bienvenue, $username !");
      _goToDashboard();
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

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
      // Center le contenu globalement
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isRegistering ? "NOUVEAU COMPTE" : "IDENTIFICATION",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 4, 
                      color: AuraColors.electricCyan
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  if (_isRegistering) ...[
                    _buildTextField(
                      controller: _usernameController,
                      label: "Pseudo",
                      icon: Icons.person_outline,
                      validator: (value) => (value == null || value.length < 3) ? '3 caractères min.' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    validator: (value) => (value != null && value.contains('@')) ? null : 'Email invalide',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _passwordController,
                    label: "Mot de passe",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) => (value != null && value.length >= 6) ? null : '6 caractères min.',
                  ),
                  
                  const SizedBox(height: 32),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AuraColors.electricCyan))
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraColors.electricCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isRegistering ? "S'INSCRIRE" : "SE CONNECTER",
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 24),
                  
                  // Séparateur
                  Row(children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OU", style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 12)),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ]),
                  
                  const SizedBox(height: 24),

                  // 🦋 BOUTON PRONOTE (Visuel)
                  _buildSocialButton(
                    label: "Continuer avec Pronote",
                    color: const Color(0xFF005c29), // Vert Pronote approx
                    icon: Icons.school, // Faute de logo SVG pour l'instant
                    onTap: () => _showError("Intégration Pronote bientôt disponible !"),
                  ),
                  
                  const SizedBox(height: 12),

                  // BOUTON GOOGLE
                  _buildSocialButton(
                    label: "Continuer avec Google",
                    color: Colors.white.withOpacity(0.05),
                    icon: Icons.g_mobiledata,
                    onTap: () => _showError("Config Google en cours..."),
                  ),

                  const SizedBox(height: 32),

                  // Bascule Inscription / Connexion
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegistering = !_isRegistering;
                        _formKey.currentState?.reset();
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.spaceGrotesk(color: Colors.white70),
                        children: [
                          TextSpan(text: _isRegistering ? "Déjà un compte ? " : "Pas encore de compte ? "),
                          TextSpan(
                            text: _isRegistering ? "Se connecter" : "Créer un compte",
                            style: const TextStyle(color: AuraColors.electricCyan, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Mode Invité
                  TextButton(
                    onPressed: _goToDashboard,
                    child: Text("Continuer en Invité", style: GoogleFonts.spaceGrotesk(color: Colors.white30, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper pour les champs texte
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator ??
          (value) {
        if (value == null || value.isEmpty) {
          return "Champ obligatoire";
        }
        if (isPassword) {
          if (value.length < 6) return '6 caractères min.';
          return null;
        }
        if (label.toLowerCase().contains('email')) {
          final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
          if (!emailRegex.hasMatch(value)) {
            return "Format email invalide (ex: neo@onlineschool.fr)";
          }
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AuraColors.electricCyan),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AuraColors.electricCyan.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AuraColors.electricCyan)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AuraColors.softCoral)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AuraColors.softCoral)),
        filled: true,
        fillColor: AuraColors.abyssalGrey,
      ),
    );
  }

  // Helper pour les boutons sociaux
  Widget _buildSocialButton({required String label, required Color color, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
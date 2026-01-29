import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/aura_orb.dart';
import '../../learning/screens/session_screen.dart';
import '../../../providers/user_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _username;
  bool _isGuest = true;

  String selectedSubject = 'Maths'; // Matière par défaut

  final List<Map<String, dynamic>> subjects = [
    {'name': 'Maths', 'icon': Icons.calculate},
    {'name': 'Histoire', 'icon': Icons.history_edu},
    {'name': 'Anglais', 'icon': Icons.translate},
    {'name': 'Sciences', 'icon': Icons.science},
  ];

  // Fonction pour construire une puce néon
  Widget _buildSubjectChip(String name, IconData icon) {
    bool isSelected = selectedSubject == name;
    return GestureDetector(
      onTap: () => setState(() => selectedSubject = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AuraColors.electricCyan.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AuraColors.electricCyan : Colors.white24,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [BoxShadow(color: AuraColors.electricCyan.withOpacity(0.5), blurRadius: 10)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AuraColors.electricCyan : Colors.white60, size: 20),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() => _isGuest = false);
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
        // En cas d'erreur silencieuse
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentAura = ref.watch(auraProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40), // Pour équilibrer

                    // TITRE DYNAMIQUE
                    Column(
                      children: [
                        Text(
                          _username != null ? "AURA DE ${_username!.toUpperCase()}" : "TON AURA",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold,
                                color: _isGuest ? Colors.white70 : AuraColors.electricCyan,
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
                          Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        }
                      },
                      icon: Icon(
                        _isGuest ? Icons.login : Icons.account_circle,
                        color: _isGuest ? AuraColors.softCoral : AuraColors.electricCyan,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // SCORE
                Text(
                  "$currentAura",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 56, // Légèrement plus petit
                    fontWeight: FontWeight.bold,
                    color: AuraColors.electricCyan,
                    shadows: [
                      Shadow(color: AuraColors.electricCyan.withOpacity(0.8), blurRadius: 30)
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const AuraOrb(size: 240), // Réduit de 280 à 240

                const SizedBox(height: 32),

                Text(
                  _isGuest ? "Mode Invité" : "Prêt à briller, $_username ?",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "6 minutes pour faire la différence.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                Text("CHOISIS TA MATIÈRE", style: AuraTextStyles.subtitle),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: subjects.map((s) => _buildSubjectChip(s['name'], s['icon'])).toList(),
                ),

                const SizedBox(height: 40),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionScreen(subject: selectedSubject),
                        ),
                      );
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
      ),
    );
  }
}
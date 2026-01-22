import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Pour formater la date (Ajoute intl dans pubspec si besoin, sinon utilise une version simple)

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Récupérer le Profil (Points + Pseudo)
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // 2. Récupérer l'Historique (5 dernières sessions)
      final historyResponse = await Supabase.instance.client
          .from('study_sessions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false) // Du plus récent au plus vieux
          .limit(5);

      if (mounted) {
        setState(() {
          _profileData = profileResponse;
          _history = historyResponse;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur profil: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Petit algorythme de Gamification 🎮
  String _getRank(int score) {
    if (score < 500) return "Novice";
    if (score < 1500) return "Apprenti";
    if (score < 3000) return "Initié";
    if (score < 5000) return "Maître";
    return "Légende Aura";
  }

  Color _getRankColor(int score) {
    if (score < 500) return Colors.white54;
    if (score < 1500) return AuraColors.mintNeon;
    if (score < 3000) return AuraColors.electricCyan;
    if (score < 5000) return Colors.amber;
    return Colors.purpleAccent;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AuraColors.electricCyan)));
    }

    final int score = _profileData?['aura_points'] ?? 0;
    final String username = _profileData?['username'] ?? "Voyageur";
    final String rank = _getRank(score);
    final Color rankColor = _getRankColor(score);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("MON DOSSIER", style: Theme.of(context).textTheme.bodyMedium),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AuraColors.softCoral),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                // On pourrait rediriger vers LoginScreen ici
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. AVATAR & RANG
            CircleAvatar(
              radius: 50,
              backgroundColor: rankColor.withOpacity(0.2),
              child: Text(
                username.substring(0, 1).toUpperCase(),
                style: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.bold, color: rankColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rankColor),
              ),
              child: Text(rank.toUpperCase(), style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),

            const SizedBox(height: 40),

            // 2. STATS RAPIDES
            Row(
              children: [
                _buildStatCard("Total Points", "$score", Icons.auto_awesome),
                const SizedBox(width: 16),
                _buildStatCard("Sessions", "${_history.length}", Icons.history), // Juste pour l'exemple (c'est le nombre affiché)
              ],
            ),

            const SizedBox(height: 40),
            Align(alignment: Alignment.centerLeft, child: Text("DERNIÈRES ACTIVITÉS", style: Theme.of(context).textTheme.bodyMedium)),
            const SizedBox(height: 16),

            // 3. HISTORIQUE
            if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Aucune session enregistrée pour l'instant.", style: TextStyle(color: Colors.white30)),
              )
            else
              ..._history.map((session) {
                // Formatage simple de la date
                final date = DateTime.parse(session['created_at']).toLocal();
                final dateStr = "${date.day}/${date.month} à ${date.hour}h${date.minute}";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AuraColors.abyssalGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session['game_mode'] ?? "Entraînement", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(dateStr, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                        ],
                      ),
                      Text(
                        "+${session['points_earned']}",
                        style: const TextStyle(color: AuraColors.mintNeon, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AuraColors.abyssalGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: AuraColors.electricCyan, size: 30),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(color: Colors.white30, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
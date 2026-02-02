import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 
import 'package:aura_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:aura_app/features/dashboard/screens/session_review_screen.dart';
import 'package:aura_app/features/dashboard/widgets/stats_charts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_app/providers/user_provider.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
          .limit(50);

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

  Color _getRankColor(int score) {
    if (score < 1000) return Colors.white54;
    if (score < 100000) return AuraColors.electricCyan;
    return AuraColors.purple; // Aura INFINIE
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AuraColors.electricCyan)));
    }

    final int score = _profileData?['aura_points'] ?? 0;
    final String username = _profileData?['username'] ?? "Voyageur";
    
    // Utilisation dynamique du UserState pour le titre
    final String rankTitle = ref.read(userProvider).getTitle(score);
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
              ref.invalidate(userProvider);
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const DashboardScreen()), // On recharge DashboardScreen
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. AVATAR & RANG
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: rankColor.withOpacity(0.2),
                child: Text(
                  username.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.bold, color: rankColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: rankColor),
                ),
                child: Text(rankTitle.toUpperCase(), style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),

            const SizedBox(height: 40),

            // 2. STATS RAPIDES
            Row(
              children: [
                _buildStatCard("Total Points", "$score", Icons.auto_awesome),
                const SizedBox(width: 16),
                _buildStatCard("Sessions", "${_history.length}", Icons.history), 
              ],
            ),

            const SizedBox(height: 40),
            
            // 2.5 GALERIE DES SCEAUX
            Center(child: Text("GALERIE DES SCEAUX", style: AuraTextStyles.subtitle, textAlign: TextAlign.center)),
            const SizedBox(height: 16),
            const BadgeGrid(),

            const SizedBox(height: 40),
            
            // 2.7 STATISTIQUES AVANCÉES
            const StatsSection(),
            
            const SizedBox(height: 40),
            
            Center(child: Text("DERNIÈRES ACTIVITÉS", style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center)),
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
                  decoration: BoxDecoration(
                    color: AuraColors.abyssalGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final answers = session['answers_json'];
                      if (answers != null && answers is List && answers.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SessionReviewScreen(
                              answers: answers,
                              dateStr: dateStr,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Détails non disponibles pour cette session.")),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                          Row(
                            children: [
                              Text(
                                "+${session['points_earned']}",
                                style: const TextStyle(color: AuraColors.mintNeon, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class BadgeGrid extends ConsumerWidget {
  const BadgeGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);

    // Liste des Badges disponibles (Ordre fixe conforme à la nouvelle logique)
    final allBadges = [
      {'id': 'streak_7', 'label': 'Hebdo', 'icon': Icons.verified_user},
      {'id': 'streak_30', 'label': 'Mensuel', 'icon': Icons.shield},
      {'id': 'streak_90', 'label': 'Trimestre', 'icon': Icons.workspace_premium},
      {'id': 'streak_365', 'label': 'Solaire', 'icon': Icons.star},
    ];

    return badgesAsync.when(
      data: (badgeCounts) {
        if (badgeCounts.isEmpty) {
          // Log pour debug si besoin
          print("Aucun badge trouvé pour l'utilisateur.");
        }
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: allBadges.map((badge) {
            final count = badgeCounts[badge['id']] ?? 0;
            return _buildBadgeItem(badge, count);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AuraColors.electricCyan)),
      error: (err, stack) => const Text("Erreur chargement badges", style: TextStyle(color: AuraColors.softCoral)),
    );
  }

  Widget _buildBadgeItem(Map<String, dynamic> badge, int count) {
    final bool isUnlocked = count > 0;
    final color = isUnlocked ? AuraColors.electricCyan : Colors.white.withOpacity(0.2);
    final borderColor = isUnlocked ? AuraColors.electricCyan : Colors.white10;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AuraColors.abyssalGrey,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
                boxShadow: isUnlocked ? [
                  BoxShadow(color: AuraColors.electricCyan.withOpacity(0.4), blurRadius: 10, spreadRadius: 1)
                ] : [],
              ),
              child: Icon(badge['icon'] as IconData, color: color, size: 28),
            ),
            // Pastille de quantité (Badge Chip)
            if (count >= 1)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AuraColors.electricCyan,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "x$count",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          badge['label'] as String,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10, 
            color: isUnlocked ? Colors.white : Colors.white24,
            fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
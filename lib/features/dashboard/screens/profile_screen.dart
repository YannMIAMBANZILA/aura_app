import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 
import 'package:aura_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_app/providers/user_provider.dart';

// Provider pour récupérer les badges de l'utilisateur
final badgesProvider = FutureProvider<List<String>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  try {
    final response = await Supabase.instance.client
        .from('badges')
        .select('badge_type')
        .eq('user_id', user.id);
    
    // On retourne une liste de String (ex: ['Hebdo', 'Mensuel'])
    return (response as List).map((e) => e['badge_type'] as String).toList();
  } catch (e) {
    print("Erreur badges: $e");
    return [];
  }
});

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
              child: Text(rankTitle.toUpperCase(), style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
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
            Align(alignment: Alignment.centerLeft, child: Text("GALERIE DES SCEAUX", style: AuraTextStyles.subtitle)),
            const SizedBox(height: 16),
            const BadgeGrid(),

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

class BadgeGrid extends ConsumerWidget {
  const BadgeGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);

    // Liste des Badges disponibles (Ordre fixe)
    final allBadges = [
      {'id': 'Hebdo', 'label': 'Hebdo', 'icon': Icons.verified_user},
      {'id': 'Mensuel', 'label': 'Mensuel', 'icon': Icons.shield},
      {'id': 'Trimestriel', 'label': 'Trimestre', 'icon': Icons.workspace_premium},
      {'id': 'Semestriel', 'label': 'Semestre', 'icon': Icons.military_tech},
      {'id': 'Annuel', 'label': 'Annuel', 'icon': Icons.star},
    ];

    return badgesAsync.when(
      data: (unlockedBadges) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: allBadges.map((badge) {
            final isUnlocked = unlockedBadges.contains(badge['id']);
            return _buildBadgeItem(badge, isUnlocked);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AuraColors.electricCyan)),
      error: (err, stack) => const Text("Erreur chargement badges", style: TextStyle(color: AuraColors.softCoral)),
    );
  }

  Widget _buildBadgeItem(Map<String, dynamic> badge, bool isUnlocked) {
    final color = isUnlocked ? AuraColors.electricCyan : Colors.white.withOpacity(0.2);
    final borderColor = isUnlocked ? AuraColors.electricCyan : Colors.white10;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AuraColors.abyssalGrey,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isUnlocked ? [
              BoxShadow(color: AuraColors.electricCyan.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)
            ] : [],
          ),
          child: Icon(badge['icon'] as IconData, color: color, size: 28),
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
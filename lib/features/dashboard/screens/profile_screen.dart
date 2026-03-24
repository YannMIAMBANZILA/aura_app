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
import 'package:aura_app/features/learning/screens/revision_card_list_screen.dart';
import 'package:aura_app/features/agenda/screens/timetable_setup_screen.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  bool _isGuest = true;
  Map<String, dynamic>? _profileData;
  List<dynamic> _history = [];
  String? _selectedGrade;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() => _isGuest = false);

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
          _selectedGrade = profileResponse['grade_level'] as String?;
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
              await ref.read(auraProvider.notifier).logout();
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
            const SizedBox(height: 24),

            // SÉLECTEUR DE CLASSE
            if (!_isGuest)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: AuraColors.abyssalGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: AuraColors.abyssalGrey,
                      value: _selectedGrade,
                      hint: const Text("Sélectionne ta classe", style: TextStyle(color: Colors.white54, fontSize: 14)),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AuraColors.electricCyan),
                      items: ['6ème', '5ème', '4ème', '3ème', 'Seconde', 'Première', 'Terminale'].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (newVal) async {
                        if (newVal != null) {
                          setState(() => _selectedGrade = newVal);
                          final user = Supabase.instance.client.auth.currentUser;
                          if (user != null) {
                            try {
                              await Supabase.instance.client
                                  .from('profiles')
                                  .update({'grade_level': newVal})
                                  .eq('id', user.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Classe mise à jour ! 🎓"),
                                    backgroundColor: AuraColors.mintNeon,
                                  ),
                                );
                              }
                            } catch(e) {
                              print("Erreur maj classe: $e");
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // 2. STATS RAPIDES (Ligne de 3)
            Row(
              children: [
                _buildStatCard("Aura Points", "$score", Icons.auto_awesome),
                const SizedBox(width: 12),
                _buildStatCard("Sessions", "${_history.length}", Icons.history),
                const SizedBox(width: 12),
                _buildStatCard(
                  "Mes Fiches", 
                  "Voir", 
                  Icons.sticky_note_2_outlined, 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevisionCardListScreen()))
                ),
              ],
            ),

            const SizedBox(height: 40),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00E5FF), // Texte et icône en Cyan
                  side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5), // Bordure Cyan
                  minimumSize: const Size(double.infinity, 55), // Prend toute la largeur
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: const Color(0xFF00E5FF).withOpacity(0.05), // Léger fond bleuté
                ),
                icon: const Icon(Icons.calendar_today, size: 22),
                label: const Text(
                  'Mon Emploi du Temps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimetableSetupScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30), // Espace avant "GALERIE DES SCEAUX"

            // 2.5 GALERIE DES SCEAUX
            Center(child: Text("GALERIE DES SCEAUX", style: AuraTextStyles.subtitle, textAlign: TextAlign.center)),
            const SizedBox(height: 16),
            const BadgeGrid(),

            const SizedBox(height: 40),
            
            // 2.7 STATISTIQUES AVANCÉES
            const StatsSection(),
            
            const SizedBox(height: 40),

            // 3. DERNIÈRES ACTIVITÉS AVEC FILTRES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("DERNIÈRES ACTIVITÉS", style: Theme.of(context).textTheme.bodyMedium),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sort_rounded, color: Colors.white54, size: 20),
                      onPressed: () => _showSortOptions(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // LISTE DES ACTIVITÉS
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  String _sortMode = 'date'; // 'date', 'points', 'subject'
  int _currentPage = 0;
  final int _pageSize = 5;

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.deepSpaceBlue,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today, color: AuraColors.electricCyan),
            title: const Text("Trier par date", style: TextStyle(color: Colors.white)),
            onTap: () { setState(() => _sortMode = 'date'); Navigator.pop(context); },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline, color: AuraColors.electricCyan),
            title: const Text("Trier par points", style: TextStyle(color: Colors.white)),
            onTap: () { setState(() => _sortMode = 'points'); Navigator.pop(context); },
          ),
          ListTile(
            leading: const Icon(Icons.subject, color: AuraColors.electricCyan),
            title: const Text("Trier par matière", style: TextStyle(color: Colors.white)),
            onTap: () { setState(() => _sortMode = 'subject'); Navigator.pop(context); },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    if (_history.isEmpty) {
      return const Center(child: Text("Aucune activité", style: TextStyle(color: Colors.white24)));
    }

    final selectedIndex = ref.watch(selectedBarIndexProvider);
    final timeframe = ref.watch(timeframeProvider);
    final statsAsync = ref.watch(statsProvider);

    // Filter by selected bar
    List<dynamic> filteredList = List.from(_history);
    if (selectedIndex != null) {
      statsAsync.whenData((stats) {
        if (selectedIndex >= 0 && selectedIndex < stats.xLabels.length) {
          final label = stats.xLabels[selectedIndex];
          filteredList = filteredList.where((session) {
            final date = DateTime.parse(session['created_at']).toLocal();
            if (timeframe == Timeframe.week) {
              return date.weekday == (selectedIndex + 1);
            } else if (timeframe == Timeframe.day) {
              final key = "${date.day}/${date.month}";
              return key == label;
            } else {
              return date.month == (selectedIndex + 1);
            }
          }).toList();
        }
      });
    }

    // Tri
    if (_sortMode == 'points') {
      filteredList.sort((a, b) => (b['points_earned'] as int).compareTo(a['points_earned'] as int));
    } else if (_sortMode == 'subject') {
      filteredList.sort((a, b) => (a['subject'] ?? '').compareTo(b['subject'] ?? ''));
    } else {
      filteredList.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
    }

    // Pagination
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize) < filteredList.length ? (startIndex + _pageSize) : filteredList.length;
    final pagedList = startIndex < filteredList.length ? filteredList.sublist(startIndex, endIndex) : [];

    return Column(
      children: [
        if (selectedIndex != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: AuraColors.electricCyan, size: 14),
                const SizedBox(width: 8),
                Text("Filtre actif", style: GoogleFonts.inter(color: AuraColors.electricCyan, fontSize: 12)),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(selectedBarIndexProvider.notifier).state = null,
                  child: const Text("Effacer", style: TextStyle(color: Colors.white30, fontSize: 12)),
                ),
              ],
            ),
          ),
        ...pagedList.map((session) {
          final date = DateTime.parse(session['created_at']).toLocal();
          final dateStr = DateFormat('dd/MM HH:mm').format(date);
          final subject = session['subject'] ?? "Général";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AuraColors.abyssalGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ListTile(
              onTap: () {
                if (session['game_mode'] == 'Session Rapide') {
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
                       const SnackBar(content: Text("Détails non disponibles pour ce quiz.")),
                     );
                   }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text("Cours terminé : ${session['chapter'] ?? session['subject']}")),
                  );
                }
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: session['game_mode'] == 'Session Rapide' 
                      ? AuraColors.electricCyan.withOpacity(0.1)
                      : AuraColors.mintNeon.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  session['game_mode'] == 'Session Rapide' ? Icons.bolt : Icons.menu_book, 
                  color: session['game_mode'] == 'Session Rapide' ? AuraColors.electricCyan : AuraColors.mintNeon, 
                  size: 20
                ),
              ),
              title: Text(session['game_mode'] ?? "Session", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("$dateStr • $subject • +${session['points_earned']} pts", style: const TextStyle(color: Colors.white30, fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
            ),
          );
        }),
        if (filteredList.isEmpty && selectedIndex != null)
          const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Aucune activité pour cette période", style: TextStyle(color: Colors.white24)),
          )),
        const SizedBox(height: 16),
        // Pagination Controls
        if (filteredList.length > _pageSize)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white54),
                onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
              ),
              Text("Page ${_currentPage + 1}", style: const TextStyle(color: Colors.white54)),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white54),
                onPressed: endIndex < filteredList.length ? () => setState(() => _currentPage++) : null,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: AuraColors.abyssalGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isGuest && label == "Sessions" ? Colors.transparent : Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, color: AuraColors.electricCyan, size: 24),
              const SizedBox(height: 8),
              Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
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
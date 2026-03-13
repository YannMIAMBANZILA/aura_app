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
import '../../../services/notification_service.dart';
import '../../chat/screens/chat_screen.dart';
import '../../learning/screens/lesson_selection_screen.dart';


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
    {'name': 'Maths', 'icon': Icons.calculate, 'color': AuraColors.cyan},
    {'name': 'Français', 'icon': Icons.menu_book, 'color': AuraColors.purple},
    {'name': 'Physique', 'icon': Icons.science, 'color': AuraColors.green},
    {'name': 'Histoire', 'icon': Icons.history_edu, 'color': AuraColors.orange},
    {'name': 'Anglais', 'icon': Icons.translate, 'color': AuraColors.cyan},
    {'name': 'Philo', 'icon': Icons.psychology, 'color': AuraColors.purple},
  ];

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
            .select('username, last_study_date')
            .eq('id', user.id)
            .single();

        if (mounted && data['username'] != null) {
          setState(() {
            _username = data['username'];
          });
        }
        
        // Vérification de la notification quotidienne
        bool hasStudiedToday = false;
        if (data['last_study_date'] != null) {
           final lastDate = DateTime.parse(data['last_study_date']).toLocal();
           final now = DateTime.now();
           if (lastDate.year == now.year && lastDate.month == now.month && lastDate.day == now.day) {
             hasStudiedToday = true;
           }
        }
        // Programme le rappel quotidien
        await NotificationService().scheduleDailyReminder(hasStudiedToday);


      } catch (e) {
        // En cas d'erreur silencieuse
        print("Erreur checkUser: $e");
      }
    }
  }

  // Widget avec l'effet de Halo
  Widget _buildSubjectChip(Map<String, dynamic> subject) {
    bool isSelected = selectedSubject == subject['name'];
    Color color = subject['color'];

    return GestureDetector(
      onTap: () => setState(() => selectedSubject = subject['name']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: 2,
          ),
          // L'EFFET DE HALO (GLOW)
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              subject['icon'],
              color: isSelected ? color : Colors.white38,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              subject['name'],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentAura = ref.watch(auraProvider);

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: _buildDrawer(context),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AuraColors.electricCyan,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage('assets/images/laura_avatar.png'),
                        ),
                      ),
                    ),

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

                    // MENU BURGER
                    IconButton(
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: AuraColors.electricCyan,
                        size: 28,
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

                const AuraOrb(size: 240), 

                const SizedBox(height: 32),

                Text(
                  _isGuest ? "Mode Invité" : "Prêt à briller, $_username ?",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "1 minute pour faire la différence.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                // BOUTONS D'ACTION
                Column(
                  children: [
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
                        onPressed: () => _showSubjectPicker(context, isQuiz: true),
                        child: Text(
                          "S'ENTRAÎNER (QUIZ)",
                          style: GoogleFonts.spaceGrotesk(
                            color: AuraColors.electricCyan,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AuraColors.mintNeon, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          backgroundColor: AuraColors.mintNeon.withOpacity(0.05),
                        ),
                        onPressed: () => _showSubjectPicker(context, isQuiz: false),
                        child: Text(
                          "APPRENDRE UN COURS",
                          style: GoogleFonts.spaceGrotesk(
                            color: AuraColors.mintNeon,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 👇 MENU BURGER (DRAWER) PREMIUM
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AuraColors.deepSpaceBlue,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: Column(
          children: [
            // Drawer Header avec Laura
            DrawerHeader(
              decoration: BoxDecoration(
                color: AuraColors.electricCyan.withOpacity(0.05),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: AuraColors.electricCyan,
                      child: CircleAvatar(
                        radius: 33,
                        backgroundImage: AssetImage('assets/images/laura_avatar.png'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "AURA APP",
                      style: GoogleFonts.spaceGrotesk(
                        color: AuraColors.electricCyan,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDrawerTile(
                    icon: Icons.person_outline_rounded,
                    title: "Profil élève",
                    onTap: () {
                      Navigator.pop(context);
                      if (_isGuest) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                      }
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.gavel_rounded,
                    title: "Mentions légales",
                    onTap: () {
                      // Action pour mentions légales
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Politique de confidentialité",
                    onTap: () {
                      // Action pour confidentialité
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.mail_outline_rounded,
                    title: "Nous contacter",
                    onTap: () {
                      // Action pour contact
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.settings_outlined,
                    title: "Paramètres de l'app",
                    onTap: () {
                      // Action pour paramètres
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            
            // Version & Copyright
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "Version 1.0.0 • © 2026 Aura",
                style: GoogleFonts.inter(color: Colors.white24, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AuraColors.electricCyan, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
      hoverColor: AuraColors.electricCyan.withOpacity(0.1),
    );
  }

  // 👇 SÉLECTEUR DE MATIÈRE PREMIUM (MODAL)
  void _showSubjectPicker(BuildContext context, {required bool isQuiz}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AuraColors.deepSpaceBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Colors.white12, width: 1)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Text(
              "CHOISIS TA MATIÈRE",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: isQuiz ? AuraColors.electricCyan : AuraColors.mintNeon,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final s = subjects[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Ferme le modal
                      if (isQuiz) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SessionScreen(subject: s['name'])));
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonSelectionScreen(
                              subject: s['name'],
                              subjectColor: s['color'],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: s['color'].withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: s['color'].withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(s['icon'], color: s['color'], size: 30),
                          const SizedBox(height: 8),
                          Text(
                            s['name'],
                            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

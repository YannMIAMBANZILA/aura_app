import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../models/lesson_content.dart';
import '../providers/lesson_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'lesson_chat_screen.dart';
import 'session_screen.dart';
import 'revision_card_edit_screen.dart';
import '../../../services/chat_service.dart';
import '../../../models/question.dart';
import '../../../providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dashboard/widgets/stats_charts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LessonCarouselScreen extends ConsumerStatefulWidget {
  final String subject;
  final String chapter;

  const LessonCarouselScreen({
    super.key,
    required this.subject,
    required this.chapter,
  });

  @override
  ConsumerState<LessonCarouselScreen> createState() => _LessonCarouselScreenState();
}

class _LessonCarouselScreenState extends ConsumerState<LessonCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _rewardAwarded = false;
  
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.5); // Normal speed
    await _flutterTts.setPitch(1.2); // Cool voice pitch
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  String _getCurrentPageText(LessonContent content, int index) {
    if (index == 0) return "Introduction. " + content.description;
    
    int summaryLength = content.fullSummary.length;
    if (index <= summaryLength) {
      final part = content.fullSummary[index - 1];
      return "${part.title}. ${part.content}"; 
    }
    
    int afterSum = index - summaryLength;
    if (afterSum == 1) return "Exemple concret. " + content.example;
    if (afterSum == 2) return "Point Pro. Métier : ${content.proPointCareer}. Application : ${content.proPointApplication}";
    if (afterSum == 3) return "À retenir. ${content.keyPoints.join('. ')}";
    if (afterSum == 4) return "C'est l'heure du check ! Laura a préparé quelques questions pour voir si tu as tout bien compris. Prêt ?";
    if (afterSum == 5) return "Génère ta fiche de révision ! Laura peut créer une fiche personnalisée basée sur tes points clés.";
    
    return "";
  }

  void _toggleSpeak(LessonState state) async {
    if (state.lessonContent == null) return;
    
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      String textToSpeak = _getCurrentPageText(state.lessonContent!, _currentPage);
      
      // Nettoyage Markdown et Emojis pour la synthèse vocale
      String cleanText = textToSpeak.replaceAll(RegExp(r'[*#_~`]'), '');
      // Suppression des URL d'images Markdown ![alt](url)
      cleanText = cleanText.replaceAll(RegExp(r'!\[.*?\]\([^)]+\)'), '');
      cleanText = cleanText.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true), '');
      
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(cleanText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonProvider((subject: widget.subject, chapter: widget.chapter)));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AuraColors.deepSpaceBlue, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, lessonState),
              Expanded(
                child: _buildContent(lessonState),
              ),
              if (lessonState.lessonContent != null) _buildPageIndicator(lessonState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LessonState lessonState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chapter.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    color: AuraColors.electricCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "Cours interactif avec Laura",
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_up : Icons.volume_mute,
              color: AuraColors.electricCyan,
              size: 28,
            ),
            onPressed: () => _toggleSpeak(lessonState),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/laura_avatar.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LessonState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AuraColors.electricCyan),
            const SizedBox(height: 24),
            Text(
              "Laura prépare ton cours...",
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AuraColors.softCoral, size: 48),
            const SizedBox(height: 16),
            Text(state.error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.refresh(lessonProvider((subject: widget.subject, chapter: widget.chapter))),
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    final content = state.lessonContent;
    if (content == null) return const SizedBox.shrink();

    final List<Widget> pages = [
      _buildDescriptionPage(content.description),
      ...content.fullSummary.map((p) => _buildSummaryPage(p)),
      _buildExamplePage(content.example),
      _buildProPage(content.proPointCareer, content.proPointApplication),
      _buildKeyPointsPage(content.keyPoints),
      _buildQuizIntroPage(content.quizQuestions),
      _buildRevisionCardPage(content.keyPoints),
    ];

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (idx) {
        // Couper la voix lorsqu'on change de page
        if (_isSpeaking) {
          _flutterTts.stop();
          setState(() => _isSpeaking = false);
        }
        
        setState(() => _currentPage = idx);
        
        // 💡 RÉCOMPENSE : Si on arrive à la fin (Fiche de révision)
        if (idx == pages.length - 1 && !_rewardAwarded) {
          _rewardAwarded = true;
          ref.read(auraProvider.notifier).addPoints(25);
          _saveLearningSession();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Belle lecture ! Ton Aura grandit de +25 ✨"),
              duration: Duration(seconds: 2),
              backgroundColor: AuraColors.mintNeon,
            ),
          );
        }
      },
      itemCount: pages.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: pages[index],
      ),
    );
  }

  Future<void> _saveLearningSession() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.from('study_sessions').insert({
          'user_id': user.id,
          'subject': widget.subject,
          'points_earned': 25,
          'game_mode': 'Cours Interactif',
          'chapter': widget.chapter,
        });
        // Invalidate stats to refresh charts
        ref.invalidate(statsProvider);
      } catch (e) {
        print("Erreur save learning session: $e");
      }
    }
  }

  Widget _buildPageIndicator(LessonState state) {
    final pagesCount = (state.lessonContent?.fullSummary.length ?? 0) + 5;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pagesCount,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            width: _currentPage == index ? 24 : 8,
            decoration: BoxDecoration(
              color: _currentPage == index ? AuraColors.electricCyan : Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child, Color accentColor = AuraColors.electricCyan, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: accentColor, size: 28),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    color: accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }

  Widget _buildDescriptionPage(String description) {
    return _buildCard(
      title: "Introduction",
      icon: Icons.lightbulb_outline,
      child: Text(
        description,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 18, height: 1.6),
      ),
    );
  }

  Widget _buildSummaryPage(SummaryPart part) {
    return _buildCard(
      title: part.title,
      icon: Icons.menu_book,
      child: MarkdownBody(
        data: part.content,
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.inter(color: Colors.white70, fontSize: 16, height: 1.6),
          strong: const TextStyle(color: AuraColors.mintNeon),
        ),
        imageBuilder: (uri, title, alt) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: AuraColors.electricCyan,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamplePage(String example) {
    return _buildCard(
      title: "Exemple Concret",
      icon: Icons.rocket_launch_outlined,
      accentColor: AuraColors.purple,
      child: MarkdownBody(
        data: example,
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.inter(color: Colors.white70, fontSize: 16, height: 1.6, fontStyle: FontStyle.italic),
        ),
        imageBuilder: (uri, title, alt) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: AuraColors.purple,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProPage(String career, String application) {
    return _buildCard(
      title: "Point Pro",
      icon: Icons.work_outline,
      accentColor: AuraColors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Métier : $career",
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            application,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsPage(List<String> points) {
    return _buildCard(
      title: "À Retenir",
      icon: Icons.auto_awesome,
      accentColor: AuraColors.mintNeon,
      child: Column(
        children: points.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: AuraColors.mintNeon, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildQuizIntroPage(List<LessonQuizQuestion> questions) {
    return Container(
      decoration: BoxDecoration(
        color: AuraColors.electricCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AuraColors.electricCyan.withOpacity(0.5), width: 2),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology_outlined, color: AuraColors.electricCyan, size: 80),
          const SizedBox(height: 32),
          Text(
            "C'est l'heure du check !",
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Laura a préparé quelques questions pour voir si tu as tout bien compris. Prêt ?",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AuraColors.electricCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              final mappedQuestions = questions.map(
                (q) => Question.fromLessonQuiz(widget.subject, q)
              ).toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionScreen(
                    subject: widget.subject,
                    initialQuestions: mappedQuestions,
                  ),
                ),
              );
            },
            child: Text(
              "COMMENCER LA SESSION",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRevisionCardPage(List<String> keyPoints) {
    return Container(
      decoration: BoxDecoration(
        color: AuraColors.mintNeon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AuraColors.mintNeon.withOpacity(0.5), width: 2),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sticky_note_2_outlined, color: AuraColors.mintNeon, size: 80),
          const SizedBox(height: 32),
          Text(
            "Génère ta fiche de révision !",
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Laura peut créer une fiche personnalisée basée sur tes points clés. Tu pourras l'éditer, l'exporter en PDF et la retrouver dans ton profil.",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AuraColors.mintNeon,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator(color: AuraColors.mintNeon)),
              );

              try {
                final chatService = ChatService();
                final content = await chatService.generateRevisionCard(
                  widget.subject,
                  widget.chapter,
                  keyPoints,
                );
                
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RevisionCardEditScreen(
                        subject: widget.subject,
                        chapter: widget.chapter,
                        initialContent: content,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Oups, impossible de générer la fiche pour le moment. 😕")),
                  );
                }
              }
            },
            child: Text(
              "CRÉER MA FICHE MAGIQUE",
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

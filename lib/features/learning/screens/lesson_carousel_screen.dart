import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../models/lesson_content.dart';
import '../providers/lesson_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'lesson_chat_screen.dart';
import 'revision_card_edit_screen.dart';
import '../../../services/chat_service.dart';

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
              _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
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
      _buildQuizIntroPage(),
      _buildRevisionCardPage(content.keyPoints),
    ];

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (idx) => setState(() => _currentPage = idx),
      itemCount: pages.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: pages[index],
      ),
    );
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
      ),
    );
  }

  Widget _buildExamplePage(String example) {
    return _buildCard(
      title: "Exemple Concret",
      icon: Icons.rocket_launch_outlined,
      accentColor: AuraColors.purple,
      child: Text(
        example,
        style: GoogleFonts.inter(color: Colors.white70, fontSize: 16, height: 1.6, fontStyle: FontStyle.italic),
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

  Widget _buildQuizIntroPage() {
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
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonChatScreen(
                    subject: widget.subject,
                    chapter: widget.chapter,
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

import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../chat/screens/chat_screen.dart';
import 'lesson_chat_screen.dart';
import 'lesson_carousel_screen.dart';

class LessonSelectionScreen extends StatefulWidget {
  final String subject;
  final Color subjectColor;

  const LessonSelectionScreen({
    super.key,
    required this.subject,
    required this.subjectColor,
  });

  @override
  State<LessonSelectionScreen> createState() => _LessonSelectionScreenState();
}

class _LessonSelectionScreenState extends State<LessonSelectionScreen> {
  final Map<String, List<String>> _subjectChapters = {
    'Maths': ['Théorème de Thalès', 'Théorème de Pythagore', 'Calcul Littéral', 'Fonctions Affines', 'Probabilités'],
    'Français': ['L\'Accord du Participe Passé', 'Figures de Style', 'Analyse Linéaire', 'Le Surréalisme'],
    'Physique': ['Lois de Newton', 'Optique Géométrique', 'Électricité de base', 'L\'Atome'],
    'Histoire': ['La Seconde Guerre Mondiale', 'La Guerre Froide', 'La Révolution Française', 'La Renaissance'],
    'Anglais': ['Present Perfect vs Simple Past', 'Passive Voice', 'Relative Clauses', 'Conditionals'],
    'Philo': ['La Conscience', 'Le Bonheur', 'La Liberté', 'Le Travail et la Technique'],
  };

  @override
  Widget build(BuildContext context) {
    final chapters = _subjectChapters[widget.subject] ?? ['Généralités'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AuraColors.starlightWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "CHOISIS TON CHAPITRE",
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              widget.subjectColor.withOpacity(0.05),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildChapterCard(chapter),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChapterCard(String chapterName) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonCarouselScreen(
              subject: widget.subject,
              chapter: chapterName,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.subjectColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.subjectColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.subjectColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book,
                color: widget.subjectColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                chapterName,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/result_sreen.dart';
import '../../learning/widgets/flashcard_widget.dart';
import '../../../models/question.dart';
import '../../../providers/user_provider.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _scoreSession = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  String? _lauraMessage;

  @override
  void initState() {
    super.initState();
    _lauraMessage = "Laura initialise la session...";
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select()
          .limit(10); // On en prend 10 pour avoir du choix

      final data = response as List<dynamic>;
      List<Question> loadedQuestions = data.map((json) => Question.fromMap(json)).toList();

      loadedQuestions.shuffle(); 
      // On garde 3 questions pour une session rapide
      if (loadedQuestions.length > 3) {
        loadedQuestions = loadedQuestions.take(3).toList();
      }

      if (mounted) {
        setState(() {
          _questions = loadedQuestions;
          _isLoading = false;
          _lauraMessage = "Prête ? C'est parti !";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _questions = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAnswer(int index) async {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
    });

    bool isCorrect = index == _questions[_currentIndex].correctOptionIndex;

    if (isCorrect) {
      setState(() {
        _scoreSession += 50;
        _lauraMessage = "Excellent ! Ton Aura grandit. ✨";
      });
      // Mise à jour du score global (Provider)
      ref.read(auraProvider.notifier).addPoints(50);
      Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
    } else {
      setState(() => _lauraMessage = "Laura analyse ton erreur...");
      final question = _questions[_currentIndex];
      String hintToShow = question.hint; 

      if (mounted) setState(() => _lauraMessage = hintToShow);
      Future.delayed(const Duration(milliseconds: 3500), _nextQuestion);
    }
  }

  // 👇 NOUVELLE FONCTION : Sauvegarde l'historique dans le Cloud
  Future<void> _saveSessionToCloud() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    // On ne sauvegarde que si l'utilisateur est connecté (pas en mode Invité)
    if (user != null) {
      try {
        await Supabase.instance.client.from('study_sessions').insert({
          'user_id': user.id,
          'points_earned': _scoreSession,
          'game_mode': 'Session Rapide',
          // 'duration_minutes': 1, // On pourra calculer le vrai temps plus tard
        });
        print("✅ Session sauvegardée dans l'historique !");
      } catch (e) {
        print("⚠️ Erreur sauvegarde historique: $e");
      }
    }
  }

  // Modification de la fin de partie
  void _nextQuestion() async { // Ajout de async
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
        _lauraMessage = "Question suivante...";
      });
    } else {
      // 🏁 FIN DE SESSION
      
      // 1. On sauvegarde l'historique (Fire and forget)
      _saveSessionToCloud(); 

      // 2. On va vers l'écran de résultat
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: _scoreSession,
              totalQuestions: _questions.length,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AuraColors.electricCyan)));
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton(color: Colors.white), backgroundColor: Colors.transparent),
        body: const Center(child: Text("Erreur de connexion au Savoir.", style: TextStyle(color: Colors.white))),
      );
    }

    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AuraColors.starlightWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Session Rapide", style: Theme.of(context).textTheme.bodyLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: AuraColors.abyssalGrey,
                color: AuraColors.electricCyan,
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
              const SizedBox(height: 40),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_lauraMessage),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AuraColors.abyssalGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: AuraColors.mintNeon, size: 20),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _lauraMessage ?? "...",
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              FlashcardWidget(
                subject: currentQuestion.subject,
                question: currentQuestion.text,
              ),
              const Spacer(),

              ...List.generate(currentQuestion.options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildAnswerButton(
                    text: currentQuestion.options[index],
                    index: index,
                    correctIndex: currentQuestion.correctOptionIndex,
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton({required String text, required int index, required int correctIndex}) {
    Color borderColor = AuraColors.starlightWhite.withOpacity(0.2);
    Color textColor = AuraColors.starlightWhite;
    Color? backgroundColor;

    if (_isAnswered) {
      if (index == correctIndex) {
        borderColor = AuraColors.mintNeon;
        textColor = AuraColors.mintNeon;
        backgroundColor = AuraColors.mintNeon.withOpacity(0.1);
      } else if (index == _selectedAnswerIndex) {
        borderColor = AuraColors.softCoral;
        textColor = AuraColors.softCoral;
        backgroundColor = AuraColors.softCoral.withOpacity(0.1);
      }
    }

    return OutlinedButton(
      onPressed: () => _checkAnswer(index),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: borderColor, width: 2),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: textColor,
      ),
      child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}
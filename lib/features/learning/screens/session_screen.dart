import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/result_screen.dart';
import '../../learning/widgets/flashcard_widget.dart';
import '../../../models/question.dart';
import '../../../providers/user_provider.dart';
import '../../../services/notification_service.dart';
import '../../dashboard/widgets/stats_charts.dart';

class SessionScreen extends ConsumerStatefulWidget {
  final String subject;

  const SessionScreen({super.key, required this.subject});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  // _scoreSession ne sert plus qu'à l'affichage local si besoin, mais le vrai calcul est à la fin
  // int _scoreSession = 0; 
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
          .eq('grade', '3eme')    //  FILTRE 1 : Que la 3ème
          .eq('subject', widget.subject) //  FILTRE 2 : Matière choisie
          // .eq('chapter', 'Géométrie') // (Optionnel) Pour être encore plus précis
          .limit(10); // On prend 10 questions max

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

  List<Map<String, dynamic>> _sessionAnswers = []; // Pour stocker les détails

  Future<void> _checkAnswer(int index) async {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
    });

    final currentQ = _questions[_currentIndex];
    bool isCorrect = index == currentQ.correctOptionIndex;

    // Enregistrement de la réponse
    // Enregistrement de la réponse au format détaillé
    _sessionAnswers.add({
      'question': currentQ.text,
      'options': currentQ.options,
      'correct_answer_index': currentQ.correctOptionIndex,
      'selected_answer_index': index,
      'explanation': currentQ.hint,
    });

    if (isCorrect) {
      setState(() {
        _lauraMessage = "Excellent ! Ton Aura grandit. ✨";
      });
      Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
    } else {
      setState(() => _lauraMessage = "Laura analyse ton erreur...");
      String hintToShow = currentQ.hint; 

      if (mounted) setState(() => _lauraMessage = hintToShow);
      Future.delayed(const Duration(milliseconds: 3500), _nextQuestion);
    }
  }

  // 👇 Sauvegarde l'historique dans le Cloud
  Future<void> _saveSessionToCloud(int pointsEarned) async {
    final user = Supabase.instance.client.auth.currentUser;
    // On ne sauvegarde que si l'utilisateur est connecté (pas en mode Invité)
    if (user != null) {
      try {
        await Supabase.instance.client.from('study_sessions').insert({
          'user_id': user.id,
          'subject': widget.subject,
          'points_earned': pointsEarned,
          'game_mode': 'Session Rapide',
          'answers_json': _sessionAnswers, 
        });
        
        // Rafraîchir les stats
        ref.invalidate(statsProvider);
        
        print("✅ Session sauvegardée dans l'historique !");
      } catch (e) {
        print("⚠️ Erreur sauvegarde historique: $e");
      }
    }
  }

  // Modification de la fin de partie
  void _nextQuestion() async { 
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
        _lauraMessage = "Question suivante...";
      });
    } else {
      // 🏁 FIN DE SESSION
      
      // 1. Calcul des gains
      final result = await ref.read(auraProvider.notifier).completeSession();
      
      final int earnedPoints = result['points'] ?? 0;
      final int streak = result['streak'] ?? 1;
      final String? badge = result['badge'];
      
      // 2. On sauvegarde
      await _saveSessionToCloud(earnedPoints);

      // 2.2 Programme le rappel
      await NotificationService().scheduleDailyReminder(true); 

      // 3. Récupérer le score
      final int endingScore = ref.read(auraProvider);

      // 4. Navigation vers ResultScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              earnedPoints: earnedPoints,
              streak: streak,
              endingScore: endingScore,
              earnedBadge: badge,
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
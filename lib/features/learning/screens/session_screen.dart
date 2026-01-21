import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import '../../../features/learning/screens/result_sreen.dart';
import '../../learning/widgets/flashcard_widget.dart';
import '../../../models/question.dart';
import '../../../services/ai_service.dart'; 

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  // 1. Nos données
  final List<Question> _questions = [
    Question(
      subject: "HISTOIRE",
      text: "Quelle est la date exacte de la chute du Mur de Berlin ?",
      options: ["9 Novembre 1989", "8 Mai 1945", "25 Décembre 1991"],
      correctOptionIndex: 0,
      hint: "C'était juste avant la fin des années 80, en automne.",
    ),
    Question(
      subject: "MATHS",
      text: "Quelle est la dérivée de f(x) = x² ?",
      options: ["x", "2x", "2"],
      correctOptionIndex: 1,
      hint: "Rappelle-toi la formule nx^(n-1).",
    ),
    Question(
      subject: "ANGLAIS",
      text: "Comment traduit-on 'Bioluminescence' ?",
      options: ["Biolight", "Living Light", "Bioluminescence"],
      correctOptionIndex: 2,
      hint: "C'est un mot transparent, presque identique en français.",
    ),
  ];

  // 2. L'état du jeu
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  String? _lauraMessage;

  @override
  void initState() {
    super.initState();
    _lauraMessage = "Laura t'observe...";
  }

  // 3. La logique IA (Fusionnée et corrigée)
  Future<void> _checkAnswer(int index) async {
    if (_isAnswered) return;

    // Mise à jour visuelle immédiate
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
    });

    bool isCorrect = index == _questions[_currentIndex].correctOptionIndex;

    if (isCorrect) {
      // ✅ VICTOIRE
      setState(() {
        _score += 50;
        _lauraMessage = "Excellent ! Ton Aura grandit. ✨";
      });
      Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
    } else {
      // ❌ ERREUR -> APPEL IA
      setState(() {
        _lauraMessage = "Laura analyse ton erreur...";
      });

      // Récupération des données pour l'IA
      final question = _questions[_currentIndex];
      final wrongAnswer = question.options[index];
      final rightAnswer = question.options[question.correctOptionIndex];

      // Appel au service (Asynchrone)
      final hint = await OpenAIService.getHint(
        question: question.text,
        userAnswer: wrongAnswer,
        correctAnswer: rightAnswer,
        subject: question.subject,
      );

      // Mise à jour du message si l'écran est toujours là
      if (mounted) {
        setState(() {
          _lauraMessage = hint;
        });
      }

      // Délai pour lire l'indice
      Future.delayed(const Duration(milliseconds: 4000), _nextQuestion);
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
        _lauraMessage = "Focus. Prochaine question.";
      });
    } else {
      // FIN DE SESSION
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            totalQuestions: _questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Barre de progression
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: AuraColors.abyssalGrey,
                color: AuraColors.electricCyan,
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
              const SizedBox(height: 40),

              // Laura (Zone de message)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  key: ValueKey(_lauraMessage),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AuraColors.mintNeon.withOpacity(0.2),
                      child: const Icon(Icons.auto_awesome, color: AuraColors.mintNeon, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _lauraMessage ?? "...",
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // Carte de Question
              FlashcardWidget(
                subject: currentQuestion.subject,
                question: currentQuestion.text,
              ),

              const Spacer(),

              // Liste des Réponses
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

  // Design des boutons
  Widget _buildAnswerButton({
    required String text,
    required int index,
    required int correctIndex,
  }) {
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
      // 👇 ICI : On appelle bien la fonction qui contient l'IA
      onPressed: () => _checkAnswer(index),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: borderColor, width: 2),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: textColor,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}
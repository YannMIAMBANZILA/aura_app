import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import '../../learning/widgets/flashcard_widget.dart';
import '../../../models/question.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  // 1. Nos données (Simulées pour l'instant)
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

  // 2. L'état du jeu (Ce qui change)
  int _currentIndex = 0;        // Quelle question on regarde ?
  int? _selectedAnswerIndex;    // Qu'est-ce que l'élève a cliqué ?
  bool _isAnswered = false;     // A-t-il validé ?
  String? _lauraMessage;        // Ce que dit Laura

  @override
  void initState() {
    super.initState();
    _lauraMessage = "Laura t'observe...";
  }

  // 3. La logique quand on clique sur une réponse
  void _checkAnswer(int index) {
    if (_isAnswered) return; // On empêche de cliquer 2 fois

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;

      bool isCorrect = index == _questions[_currentIndex].correctOptionIndex;

      if (isCorrect) {
        _lauraMessage = "Excellent ! Ton Aura grandit. ✨";
        // On attend 1.5 seconde avant de passer à la suite
        Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
      } else {
        _lauraMessage = "Oups... ${_questions[_currentIndex].hint}";
        // Ici on laisse l'élève lire l'indice, il devra cliquer pour passer (optionnel)
        // Pour ce MVP, on passe aussi à la suite après un délai plus long
        Future.delayed(const Duration(milliseconds: 2500), _nextQuestion);
      }
    });
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
      // Fin de session !
      Navigator.pop(context); // On revient à l'accueil pour l'instant
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
              // Barre de progression dynamique
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: AuraColors.abyssalGrey,
                color: AuraColors.electricCyan,
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
              const SizedBox(height: 40),

              // Laura (Dynamique)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  key: ValueKey(_lauraMessage), // Permet l'animation du texte
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
                        _lauraMessage ?? "...", // Si _lauraMessage est null, on affiche une chaîne vide pour éviter une erreur
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // La Carte (Dynamique)
              FlashcardWidget(
                subject: currentQuestion.subject,
                question: currentQuestion.text,
              ),

              const Spacer(),

              // Liste des boutons (Générée automatiquement)
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

  // 4. Le Design du bouton qui change de couleur
  Widget _buildAnswerButton({
    required String text,
    required int index,
    required int correctIndex,
  }) {
    Color borderColor = AuraColors.starlightWhite.withOpacity(0.2);
    Color textColor = AuraColors.starlightWhite;
    Color? backgroundColor;

    // Si l'utilisateur a répondu, on change les couleurs
    if (_isAnswered) {
      if (index == correctIndex) {
        // C'est la bonne réponse -> VERT
        borderColor = AuraColors.mintNeon;
        textColor = AuraColors.mintNeon;
        backgroundColor = AuraColors.mintNeon.withOpacity(0.1);
      } else if (index == _selectedAnswerIndex) {
        // C'est la mauvaise réponse cliquée -> ROUGE
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
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}
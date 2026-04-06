import 'package:flutter/material.dart';
import 'package:aura_app/services/chat_service.dart';
import 'package:aura_app/models/question.dart';
import 'session_screen.dart';
import 'smart_loading_screen.dart';

class QuizGenerationScreen extends StatelessWidget {
  final String gradeLevel;
  final String subject;
  final String chapter;

  const QuizGenerationScreen({
    super.key,
    required this.gradeLevel,
    required this.subject,
    required this.chapter,
  });

  Future<List<Question>> _generateQuiz() async {
    final chatService = ChatService();
    final jsonResponse = await chatService.generateQuiz(
      gradeLevel, 
      subject, 
      chapter
    );
    
    final questionsData = jsonResponse['questions'] as List<dynamic>? ?? [];
    return questionsData.map((q) => Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: q['question'] ?? '',
      options: List<String>.from(q['options'] ?? []),
      correctOptionIndex: q['correctAnswerIndex'] ?? 0,
      hint: q['explanation'] ?? '',
      subject: subject,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SmartLoadingScreen<List<Question>>(
      future: _generateQuiz(),
      loadingText: "Laura prépare tes 6 questions\nsur $chapter...",
      onSuccess: (List<Question> parsedQuestions) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SessionScreen(
              subject: subject,
              initialQuestions: parsedQuestions.isNotEmpty ? parsedQuestions : null,
            )
          )
        );
      },
      onError: (e) {
        // En cas d'erreur de token ou réseau, on repasse sur la session de secours classique
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
             builder: (context) => SessionScreen(subject: subject)
          )
        );
      },
    );
  }
}

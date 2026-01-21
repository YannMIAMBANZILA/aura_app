import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getHint({
    required String question,
    required String userAnswer,
    required String correctAnswer,
    required String subject,
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      
      // Tentative d'appel à la vraie IA
      if (apiKey != null && apiKey.isNotEmpty) {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            "model": "gpt-4o-mini",
            "messages": [
              {
                "role": "system",
                "content": "Tu es Laura. Donne un indice court (max 15 mots) pour aider l'élève qui s'est trompé. Ne donne PAS la réponse."
              },
              {
                "role": "user",
                "content": "Sujet: $subject. Question: $question. Réponse élève: $userAnswer. Bonne réponse: $correctAnswer."
              }
            ],
            "temperature": 0.7,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          return data['choices'][0]['message']['content'];
        } 
      }
      
      // 👇 PLAN B : SI L'IA ECHOUE (Erreur 429 ou Pas de clé), ON SIMULE !
      return _getSimulatedHint(subject);

    } catch (e) {
      // En cas de crash total (Pas d'internet), on simule aussi
      return _getSimulatedHint(subject);
    }
  }

  // Petit cerveau de secours gratuit
  static String _getSimulatedHint(String subject) {
    switch (subject.toUpperCase()) {
      case 'MATHS':
        return "Regarde bien la puissance de x. La règle est nx^(n-1).";
      case 'HISTOIRE':
        return "C'était bien après la Seconde Guerre mondiale, vers la fin du siècle.";
      case 'ANGLAIS':
        return "Décompose le mot : 'Bio' (vie) et 'Lumen' (lumière).";
      default:
        return "Concentre-toi, tu connais la réponse. Essaie par élimination.";
    }
  }
}
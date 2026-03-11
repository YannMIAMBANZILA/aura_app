import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';
import 'dart:typed_data';

class ChatService {
  late final GenerativeModel _model;
  ChatSession? _chat;
  
  ChatService({String? systemInstruction}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: apiKey,
      systemInstruction: Content.system(
        systemInstruction ?? "You are Laura, a kind, cool, and motivating school coach for a secondary school student. "
        "Use a friendly tone, include emojis, and be pedagogical yet concise. "
        "Don't just provide the answer; explain the method so the student understands."
      ),
    );
    _chat = _model.startChat();
  }

  Future<String> getLauraResponse(String prompt, {Uint8List? imageBytes}) async {
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        GenerateContentResponse response;
        
        if (imageBytes != null) {
          final content = [
            Content.multi([
              TextPart(prompt),
              DataPart('image/jpeg', imageBytes),
            ])
          ];
          response = await _model.generateContent(content);
        } else {
          response = await _chat!.sendMessage(Content.text(prompt));
        }

        final text = response.text;
        if (text == null || text.isEmpty) {
          return "I couldn't generate a response. Maybe the topic is sensitive? 😕";
        }
        
        return text;
      } catch (e) {
        final errorStr = e.toString();
        print("❌ ERREUR GEMINI (Essai ${retryCount + 1}): $e");

        if (errorStr.contains("429") || errorStr.contains("Quota exceeded") || errorStr.contains("Please retry in")) {
          if (retryCount < maxRetries) {
            retryCount++;
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return "⏳ Whoops, I'm thinking too fast! Give me a 30-second break to catch my breath (Quota exceeded).";
        }
        
        if (errorStr.contains("Invalid API key")) {
          return "Error: Your Gemini API key is invalid. Check your .env file!";
        }
        
        if (errorStr.contains("not found")) {
          return "Error: Gemini model not found. Check if the API is enabled in Google AI Studio.";
        }

        final errorDetail = errorStr.contains(':') ? errorStr.split(':').last.trim() : errorStr;
        return "Sorry, I'm glitching a bit... Check your connection or my API key! (Details: $errorDetail)";
      }
    }
    return "Sorry, I'm a bit slow today. Please try again in a moment!";
  }
  Future<Map<String, dynamic>> generateLessonContent(String subject, String chapter) async {
    final prompt = """
      Génère un cours complet et approfondi sur le sujet '$subject' et le chapitre '$chapter'.
      Format attendu : JSON uniquement.
      
      Structure du JSON :
      {
        "description": "Brève description du cours (2-3 phrases)",
        "full_summary": [
          {"title": "Titre partie 1", "content": "Contenu détaillé partie 1 (Markdown supporté)"},
          {"title": "Titre partie 2", "content": "Contenu détaillé partie 2 (Markdown supporté)"}
        ],
        "example": "Un exemple concret ou une application pratique",
        "pro_point_career": "Un métier réel où ces connaissances sont utiles",
        "pro_point_application": "Comment c'est utilisé concrètement dans ce métier",
        "key_points": ["Point clé 1", "Point clé 2", "Point clé 3"],
        "quiz_questions": [
          {
            "question": "Une question pour tester la compréhension",
            "options": ["Réponse A", "Réponse B", "Réponse C", "Réponse D"],
            "correct_index": 0,
            "explanation": "Explication pédagogique de la bonne réponse"
          }
        ]
      }
      
      Le ton doit être pédagogique, encourageant (tu es Laura, une coach scolaire) et utiliser des emojis.
      IMPORTANT : Réponds UNIQUEMENT avec le JSON brut. Pas de texte avant ou après.
    """;

    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        final model = GenerativeModel(
          model: 'gemini-2.5-flash', 
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
          // On retire responseMimeType car certains environnements/clés API bloquent sur v1beta
          // generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );
        
        final response = await model.generateContent([
          Content.text(prompt)
        ], safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        ]);

        var text = response.text;
        
        if (text == null || text.isEmpty) {
          throw Exception("Réponse vide de l'IA (peut-être bloquée par les filtres)");
        }
        
        // Nettoyage robuste du JSON (extraction du premier bloc { ... })
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (jsonMatch != null) {
          text = jsonMatch.group(0)!;
        }

        return jsonDecode(text);
      } catch (e) {
        final errorStr = e.toString();
        print("❌ Error generating lesson (Trial ${retryCount + 1}): $e");

        if (errorStr.contains("429") || errorStr.contains("quota")) {
          if (retryCount < maxRetries) {
            retryCount++;
            await Future.delayed(const Duration(seconds: 3));
            continue;
          }
        }
        
        // Si le modèle n'est pas trouvé, on tente un fallback sur gemini-2.5-pro ou on prévient
        if (errorStr.contains("not found")) {
           print("💡 Essai d'un modèle alternatif suite à 'not found'...");
           // On pourrait tenter de changer le nom ici pour le prochain essai
        }

        rethrow;
      }
    }
    throw Exception("Échec après plusieurs tentatives.");
  }


  Future<String> generateRevisionCard(String subject, String chapter, List<String> keyPoints) async {
    final prompt = """
      Crée une fiche de révision structurée en Markdown pour le cours suivant :
      Sujet: $subject
      Chapitre: $chapter
      Points clés identifiés : ${keyPoints.join(', ')}

      La fiche doit être claire, visuelle (utilise du gras, des listes, des emojis) et pédagogique. 
      Inclus une introduction, les concepts fondamentaux détaillés, et une conclusion "Le mot de Laura".
      Réponds UNIQUEMENT avec le contenu de la fiche en Markdown. Pas de blabla autour.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Erreur lors de la génération de la fiche.";
    } catch (e) {
      print("❌ Error generating revision card: $e");
      return "Une erreur est survenue lors de la création de ta fiche. Tu peux quand même la rédiger toi-même !";
    }
  }
}

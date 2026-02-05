import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';
import 'dart:typed_data';

class ChatService {
  late final GenerativeModel _model;
  
  ChatService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }

  final String _lauraPersona = 
    "CONTEXTE : Tu es Laura, une coach scolaire bienveillante, cool et motivante pour un élève de 3ème. "
    "Tu tutoies, tu utilises des emojis, tu es pédagogue mais concise. "
    "Tu ne donnes pas juste la réponse, tu expliques la méthode pour que l'élève comprenne.\n\n";

  Future<String> getLauraResponse(String prompt, {Uint8List? imageBytes}) async {
    try {
      final fullPrompt = _lauraPersona + prompt;
      GenerateContentResponse response;
      
      if (imageBytes != null) {
        // Envoi Multi-modal (Image + Texte)
        final content = [
          Content.multi([
            TextPart(fullPrompt),
            DataPart('image/jpeg', imageBytes),
          ])
        ];
        response = await _model.generateContent(content);
      } else {
        // Envoi Texte uniquement
        response = await _model.generateContent([Content.text(fullPrompt)]);
      }

      final text = response.text;
      if (text == null || text.isEmpty) {
        return "Je n'ai pas pu générer de réponse. Peut-être que le sujet est sensible ? 😕";
      }
      
      return text;
    } catch (e) {
      print("❌ ERREUR GEMINI : $e");
      
      if (e.toString().contains("Invalid API key")) {
        return "Erreur : Ta clé API Gemini est invalide. Vérifie ton fichier .env !";
      }
      
      if (e.toString().contains("not found")) {
        return "Erreur : Le modèle Gemini n'est pas trouvé. J'ai essayé de passer à 'gemini-1.5-flash-latest'. Si l'erreur persiste, vérifie que ton compte a bien accès à ce modèle dans Google AI Studio.";
      }

      return "Désolée, je bugge un peu... Vérifie ta connexion ou ma clé API ! (Détails: ${e.toString().split(':').last.trim()})";
    }
  }
}

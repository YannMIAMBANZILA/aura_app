import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';
import 'dart:typed_data';

class ChatService {
  late final GenerativeModel _model;
  
  ChatService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        "Tu es Laura, une coach scolaire bienveillante, cool et motivante pour un élève de 3ème. "
        "Tu tutoies, tu utilises des emojis, tu es pédagogue mais concise. "
        "Tu ne donnes pas juste la réponse, tu expliques la méthode pour que l'élève comprenne."
      ),
    );
  }

  Future<String> getLauraResponse(String prompt, {Uint8List? imageBytes}) async {
    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          if (imageBytes != null) DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "Oups, j'ai eu un petit bug de connexion au savoir. Réessaie ?";
    } catch (e) {
      print("Erreur Gemini: $e");
      return "Désolée, je n'arrive pas à réfléchir correctement là... Vérifie ta connexion !";
    }
  }
}

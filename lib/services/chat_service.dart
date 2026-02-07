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
      model: 'gemini-2.0-flash-lite', 
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
}

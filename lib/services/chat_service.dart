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
  Future<Map<String, dynamic>> generateLessonContent(String subject, String chapter) async {
    final prompt = """
      Generate a deep-dive lesson on the subject '$subject' and the chapter '$chapter'.
      Return ONLY a JSON object with the following structure:
      {
        "description": "Brief description of the lesson",
        "full_summary": [
          {"title": "Part 1 title", "content": "Detailed content for part 1"},
          {"title": "Part 2 title", "content": "Detailed content for part 2"}
        ],
        "example": "A concrete example or application of the lesson content",
        "pro_point_career": "A career where this knowledge is useful",
        "pro_point_application": "How it is applied in that career",
        "key_points": ["Key point 1", "Key point 2", "Key point 3"],
        "quiz_questions": [
          {
            "question": "A question to test understanding",
            "options": ["Option A", "Option B", "Option C", "Option D"],
            "correct_index": 0,
            "explanation": "Why this answer is correct"
          }
        ]
      }
      Ensure the tone is pedagogical, friendly (like a coach named Laura), and use emojis. Use French for the content.
    """;

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
      
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text == null || text.isEmpty) {
        throw Exception("Empty response from AI");
      }
      
      return jsonDecode(text);
    } catch (e) {
      print("❌ Error generating lesson: $e");
      rethrow;
    }
  }
}

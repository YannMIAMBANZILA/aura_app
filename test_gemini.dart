import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  if (apiKey.isEmpty) {
    print('No API key found in .env');
    return;
  }

  print('Using API Key: ${apiKey.substring(0, 5)}...');

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  
  try {
    // There is no direct listModels in GenerativeModel, but we can try a simple request
    final response = await model.generateContent([Content.text('Hi')]);
    print('Success with gemini-1.5-flash: ${response.text}');
  } catch (e) {
    print('Failed with gemini-1.5-flash: $e');
  }

  try {
    final modelPro = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final responsePro = await modelPro.generateContent([Content.text('Hi')]);
    print('Success with gemini-pro: ${responsePro.text}');
  } catch (e) {
    print('Failed with gemini-pro: $e');
  }
}

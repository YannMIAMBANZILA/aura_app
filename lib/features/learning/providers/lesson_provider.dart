import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../../../models/chat_message.dart';
import '../../../services/chat_service.dart';

class LessonState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String subject;
  final String chapter;

  LessonState({
    this.messages = const [],
    this.isLoading = false,
    required this.subject,
    required this.chapter,
  });

  LessonState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return LessonState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      subject: subject,
      chapter: chapter,
    );
  }
}

class LessonNotifier extends StateNotifier<LessonState> {
  late final ChatService _chatService;

  LessonNotifier({required String subject, required String chapter}) 
    : super(LessonState(subject: subject, chapter: chapter)) {
    
    final systemInstruction = 
        "You are Laura, a kind and expert school coach. "
        "Today you are giving a deep-dive lesson on the subject '$subject' and the specific chapter '$chapter'. "
        "Start by introducing the topic briefly and then ask if the student wants to start with the basics or a specific point. "
        "Use a friendly tone, include emojis, and use pedagogical methods like analogies. "
        "Encourage the student to ask questions throughout the lesson.";

    _chatService = ChatService(systemInstruction: systemInstruction);
    
    // Initial message from Laura
    _startLesson();
  }

  Future<void> _startLesson() async {
    state = state.copyWith(isLoading: true);
    
    final prompt = "Hello Laura, I want to learn about '${state.chapter}' in '${state.subject}'. Please start the lesson!";
    final response = await _chatService.getLauraResponse(prompt);

    final lauraMessage = ChatMessage(
      text: response,
      role: MessageRole.laura,
    );

    state = state.copyWith(
      messages: [lauraMessage],
      isLoading: false,
    );
  }

  Future<void> sendMessage(String text, {Uint8List? imageBytes}) async {
    if (text.trim().isEmpty && imageBytes == null) return;

    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      imageBytes: imageBytes,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    final response = await _chatService.getLauraResponse(text, imageBytes: imageBytes);

    final lauraMessage = ChatMessage(
      text: response,
      role: MessageRole.laura,
    );

    state = state.copyWith(
      messages: [...state.messages, lauraMessage],
      isLoading: false,
    );
  }
}

final lessonProvider = StateNotifierProvider.family<LessonNotifier, LessonState, ({String subject, String chapter})>((ref, args) {
  return LessonNotifier(subject: args.subject, chapter: args.chapter);
});

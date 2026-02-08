import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../../../models/chat_message.dart';
import '../../../models/lesson_content.dart';
import '../../../services/chat_service.dart';

class LessonState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String subject;
  final String chapter;
  final LessonContent? lessonContent;
  final String? error;

  LessonState({
    this.messages = const [],
    this.isLoading = false,
    required this.subject,
    required this.chapter,
    this.lessonContent,
    this.error,
  });

  LessonState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    LessonContent? lessonContent,
    String? error,
  }) {
    return LessonState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      subject: subject,
      chapter: chapter,
      lessonContent: lessonContent ?? this.lessonContent,
      error: error,
    );
  }
}

class LessonNotifier extends StateNotifier<LessonState> {
  final ChatService _chatService = ChatService();

  LessonNotifier({required String subject, required String chapter}) 
    : super(LessonState(subject: subject, chapter: chapter)) {
    _fetchLesson();
  }

  Future<void> _fetchLesson() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await _chatService.generateLessonContent(state.subject, state.chapter);
      final lessonContent = LessonContent.fromJson(json);
      state = state.copyWith(
        lessonContent: lessonContent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Erreur lors de la génération du cours. Réessaie !",
      );
    }
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

  void addLauraMessage(String text) {
     final lauraMessage = ChatMessage(
      text: text,
      role: MessageRole.laura,
    );
    state = state.copyWith(
      messages: [...state.messages, lauraMessage],
    );
  }

  void startQuizSession() {
    if (state.messages.isNotEmpty || state.lessonContent == null) return;
    
    final firstQuestion = state.lessonContent!.quizQuestions.first;
    final optionsText = firstQuestion.options.asMap().entries.map((e) => "${e.key + 1}. ${e.value}").join("\n");
    
    final lauraText = "Super ! Voyons ce que tu as retenu. 💡\n\n**${firstQuestion.question}**\n\n$optionsText";
    
    addLauraMessage(lauraText);
  }
}

final lessonProvider = StateNotifierProvider.family<LessonNotifier, LessonState, ({String subject, String chapter})>((ref, args) {
  return LessonNotifier(subject: args.subject, chapter: args.chapter);
});

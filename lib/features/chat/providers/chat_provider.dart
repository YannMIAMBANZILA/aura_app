import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/chat_message.dart';
import '../../../services/chat_service.dart';
import 'dart:typed_data';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService = ChatService();

  ChatNotifier() : super(ChatState(messages: [
    ChatMessage(
      text: "Salut ! Je suis Laura, ta coach. En quoi puis-je t'aider aujourd'hui ? 🎓",
      role: MessageRole.laura,
    )
  ]));

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

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

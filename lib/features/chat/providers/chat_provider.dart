import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../models/chat_message.dart';
import '../../../services/chat_service.dart';
import 'dart:typed_data';

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'],
      title: map['title'],
      messages: (map['messages'] as List).map((m) => ChatMessage.fromMap(m)).toList(),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

class ChatState {
  final List<ChatSession> history;
  final String? activeSessionId;
  final List<ChatMessage> currentMessages;
  final bool isLoading;

  ChatState({
    this.history = const [],
    this.activeSessionId,
    this.currentMessages = const [],
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatSession>? history,
    String? activeSessionId,
    List<ChatMessage>? currentMessages,
    bool? isLoading,
  }) {
    return ChatState(
      history: history ?? this.history,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService = ChatService();
  final _uuid = const Uuid();

  ChatNotifier() : super(ChatState(currentMessages: _initialMessages)) {
    _loadHistory();
  }

  static final List<ChatMessage> _initialMessages = [
    ChatMessage(
      text: "Salut ! Je suis Laura, ta coach. En quoi puis-je t'aider aujourd'hui ? 🎓\n\nTu peux me demander par exemple :\n- *Explique moi le théorème de Thalès*\n- *Corrige mon texte en anglais*\n- *Quiz rapide sur la Seconde Guerre mondiale*",
      role: MessageRole.laura,
    )
  ];

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('chat_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      final history = decoded.map((e) => ChatSession.fromMap(e)).toList();
      history.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = state.copyWith(history: history);
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(state.history.map((e) => e.toMap()).toList());
    await prefs.setString('chat_history', encoded);
  }

  void startNewSession() {
    state = state.copyWith(activeSessionId: null, currentMessages: _initialMessages, isLoading: false);
  }

  void loadSession(String sessionId) {
    final session = state.history.firstWhere((s) => s.id == sessionId);
    state = state.copyWith(
      activeSessionId: sessionId,
      currentMessages: List.from(session.messages), // copiying to prevent reference issue
      isLoading: false,
    );
  }

  void deleteSession(String sessionId) {
    final newHistory = state.history.where((s) => s.id != sessionId).toList();
    if (state.activeSessionId == sessionId) {
      state = state.copyWith(history: newHistory, activeSessionId: null, currentMessages: _initialMessages);
    } else {
      state = state.copyWith(history: newHistory);
    }
    _saveHistory();
  }

  Future<void> sendMessage(String text, {Uint8List? imageBytes}) async {
    if (text.trim().isEmpty && imageBytes == null) return;

    final userMessage = ChatMessage(
      text: text,
      role: MessageRole.user,
      imageBytes: imageBytes,
    );

    state = state.copyWith(
      currentMessages: [...state.currentMessages, userMessage],
      isLoading: true,
    );

    final response = await _chatService.getLauraResponse(text, imageBytes: imageBytes);

    final lauraMessage = ChatMessage(
      text: response,
      role: MessageRole.laura,
    );

    final updatedMessages = [...state.currentMessages, lauraMessage];
    
    // Save to history
    String sessionId = state.activeSessionId ?? _uuid.v4();
    String sessionTitle = text.length > 30 ? "${text.substring(0, 30)}..." : text;

    List<ChatSession> newHistory = List.from(state.history);
    final existingSessionIndex = newHistory.indexWhere((s) => s.id == sessionId);
    
    if (existingSessionIndex >= 0) {
      newHistory[existingSessionIndex] = ChatSession(
        id: sessionId,
        title: newHistory[existingSessionIndex].title,
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );
    } else {
      newHistory.add(ChatSession(
        id: sessionId,
        title: sessionTitle.isNotEmpty ? sessionTitle : "Session image",
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      ));
    }
    
    newHistory.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    state = state.copyWith(
      currentMessages: updatedMessages,
      isLoading: false,
      activeSessionId: sessionId,
      history: newHistory,
    );

    _saveHistory();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});


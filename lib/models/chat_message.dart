import 'dart:typed_data';

enum MessageRole { user, laura }

class ChatMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.text,
    required this.role,
    DateTime? timestamp,
    this.imageBytes,
  }) : timestamp = timestamp ?? DateTime.now();
}

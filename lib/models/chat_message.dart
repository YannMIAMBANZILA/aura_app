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

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'role': role.toString(),
      'timestamp': timestamp.toIso8601String(),
      // We skip saving images to local storage to save space, unless needed.
      // If we must save it: 'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      role: map['role'] == MessageRole.user.toString() ? MessageRole.user : MessageRole.laura,
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }
}

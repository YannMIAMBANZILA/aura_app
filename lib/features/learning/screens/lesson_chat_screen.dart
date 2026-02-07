import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../models/chat_message.dart';
import '../providers/lesson_provider.dart';

class LessonChatScreen extends ConsumerStatefulWidget {
  final String subject;
  final String chapter;

  const LessonChatScreen({
    super.key,
    required this.subject,
    required this.chapter,
  });

  @override
  ConsumerState<LessonChatScreen> createState() => _LessonChatScreenState();
}

class _LessonChatScreenState extends ConsumerState<LessonChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("fr-FR"); // Français pour les leçons
    await _flutterTts.setPitch(1.1);
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  void _handleSend() {
    final text = _controller.text;
    if (text.isNotEmpty || _selectedImage != null) {
      ref.read(lessonProvider((subject: widget.subject, chapter: widget.chapter)).notifier)
          .sendMessage(text, imageBytes: _selectedImage);
      _controller.clear();
      setState(() {
        _selectedImage = null;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonProvider((subject: widget.subject, chapter: widget.chapter)));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AuraColors.electricCyan,
              backgroundImage: AssetImage('assets/images/laura_avatar.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapter.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Cours avec Laura • ${widget.subject}",
                    style: const TextStyle(fontSize: 10, color: AuraColors.mintNeon),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: lessonState.messages.length,
              itemBuilder: (context, index) {
                final message = lessonState.messages[index];
                return _MessageBubble(
                  message: message,
                  onSpeak: () => _speak(message.text),
                );
              },
            ),
          ),
          if (lessonState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.electricCyan),
                  ),
                  SizedBox(width: 12),
                  Text("Laura prépare la suite du cours...", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuraColors.abyssalGrey,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: MemoryImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => _selectedImage = null),
                ),
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_a_photo, color: AuraColors.electricCyan),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Pose tes questions sur le cours...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AuraColors.electricCyan,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _handleSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onSpeak;

  const _MessageBubble({required this.message, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.imageBytes != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: MemoryImage(message.imageBytes!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: AuraColors.abyssalGrey,
                  backgroundImage: AssetImage('assets/images/laura_avatar.png'),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? AuraColors.electricCyan.withOpacity(0.9) : AuraColors.abyssalGrey,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 20),
                    ),
                    border: isUser ? null : Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(color: isUser ? Colors.black : Colors.white, fontSize: 14),
                          strong: TextStyle(color: isUser ? Colors.black : AuraColors.mintNeon, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: onSpeak,
                            child: const Icon(Icons.volume_up, size: 16, color: AuraColors.electricCyan),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}

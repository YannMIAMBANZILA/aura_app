import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../models/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;

  final List<String> _suggestions = [
    "Explain Thales' theorem to me",
    "Correct my English text",
    "Quick quiz on World War II",
    "Tips for memorizing dates",
    "Help me with a physics assignment",
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    
    // RÉGLAGES POUR UNE VOIX PLUS JOVIALE ET DYNAMIQUE
    // Un pitch > 1.0 rend la voix un peu plus aigüe (plus jeune/souriante)
    await _flutterTts.setPitch(1.2); 
    
    // Une vitesse légèrement ajustée (0.5 est souvent la base, 0.55 donne de l'énergie)
    await _flutterTts.setSpeechRate(0.5); 
  }

  void _speak(String text) async {
    // NETTOYAGE DU TEXTE AVANT LA LECTURE
   // 1. Suppression des caractères Markdown (*, #, _, ~, `)
    String cleanText = text.replaceAll(RegExp(r'[*#_~`]'), '');
    
    // 2. Suppression des emojis
    // Cette expression régulière magique cible tous les caractères qui ressemblent à un emoji
    cleanText = cleanText.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true), '');

    // 3. Amélioration des pauses après un point et une exclamation
    cleanText = cleanText.replaceAll('\n\n', '. ');
    cleanText = cleanText.replaceAll('!', '! ');

    await _flutterTts.speak(cleanText);
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
      ref.read(chatProvider.notifier).sendMessage(text, imageBytes: _selectedImage);
      _controller.clear();
      setState(() {
        _selectedImage = null;
      });
      _scrollToBottom();
    }
  }

  void _useSuggestion(String text) {
    _controller.text = text;
    _handleSend();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AuraColors.electricCyan,
              backgroundImage: AssetImage('assets/images/laura_avatar.png'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LAURA", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 2)),
                const Text("Ta coach ", style: TextStyle(fontSize: 10, color: AuraColors.mintNeon)),
              ],
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
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return _MessageBubble(
                  message: message,
                  onSpeak: () => _speak(message.text),
                );
              },
            ),
          ),
          if (chatState.isLoading)
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
                  Text("Donne moi un moment pour réfléchir à ta requête...", style: TextStyle(color: Colors.white54, fontSize: 12)),
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
          if (ref.read(chatProvider).messages.length <= 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: _suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(suggestion),
                    labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.white10),
                    ),
                    onPressed: () => _useSuggestion(suggestion),
                  ),
                )).toList(),
              ),
            ),
          ],
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
                    hintText: "Besoin d'aide ?",
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

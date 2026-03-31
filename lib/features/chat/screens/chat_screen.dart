import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../../../providers/user_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;
  
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentlySpeakingText = "";
  final double _normalSpeechRate = 0.5;
  final double _fastSpeechRate = 0.75;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).sendMessage(widget.initialMessage!);
        _scrollToBottom();
      });
    }
  }

  void _initSpeech() async {
    await _speechToText.initialize();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setPitch(1.2); 
    await _flutterTts.setSpeechRate(_normalSpeechRate); 

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() { _isSpeaking = false; _currentlySpeakingText = ""; });
    });
    _flutterTts.setPauseHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setContinueHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
  }

  void _toggleSpeak(String text) async {
    if (_currentlySpeakingText == text && _isSpeaking) {
      await _flutterTts.pause();
    } else {
      await _flutterTts.setSpeechRate(_normalSpeechRate);
      _speak(text);
    }
  }

  void _speakFast(String text) async {
    await _flutterTts.setSpeechRate(_fastSpeechRate);
    _speak(text);
  }

  void _speak(String text) async {
    String cleanText = text.replaceAll(RegExp(r'[*#_~`]'), '');
    cleanText = cleanText.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true), '');
    cleanText = cleanText.replaceAll('\n\n', '. ');
    cleanText = cleanText.replaceAll('!', '! ');

    setState(() {
      _currentlySpeakingText = text;
      _isSpeaking = true;
    });
    
    await _flutterTts.speak(cleanText);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool isGranted = await _requestPermission(
        Permission.microphone,
        "Tu dois me permettre d'accéder à ton micro pour me parler."
      );
      if (isGranted) {
        bool available = await _speechToText.initialize();
        if (available) {
          setState(() => _isListening = true);
          _speechToText.listen(
            onResult: (val) {
               setState(() {
                 _controller.text = val.recognizedWords;
               });
            },
            localeId: 'fr_FR',
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
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

  Future<bool> _requestPermission(Permission permission, String message) async {
    var status = await permission.status;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AuraColors.abyssalGrey,
            title: const Text("Permission requise", style: TextStyle(color: Colors.white)),
            content: Text(message, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler", style: TextStyle(color: Colors.white54))),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text("Paramètres", style: TextStyle(color: AuraColors.electricCyan)),
              ),
            ],
          ),
        );
      }
      return false;
    }

    if (!status.isGranted) {
      if (mounted) {
        bool? shouldRequest = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AuraColors.abyssalGrey,
            title: const Text("Autorisation pour Laura", style: TextStyle(color: Colors.white)),
            content: Text(message, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Non", style: TextStyle(color: Colors.white54))),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Oui", style: TextStyle(color: AuraColors.electricCyan))),
            ],
          ),
        );
        if (shouldRequest != true) return false;
      }
      status = await permission.request();
    }
    return status.isGranted;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
       bool isGranted = await _requestPermission(
         Permission.camera, 
         "Tu dois me permettre d'accéder à ta caméra pour que je puisse voir ce que tu veux m'envoyer."
       );
       if (!isGranted) return;
    }

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.abyssalGrey,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AuraColors.electricCyan),
              title: const Text("Prendre une photo", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AuraColors.electricCyan),
              title: const Text("Choisir depuis la galerie", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment, color: AuraColors.electricCyan),
            onPressed: () => ref.read(chatProvider.notifier).startNewSession(),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history, color: Colors.white70),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      endDrawer: _buildHistoryDrawer(chatState),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatState.currentMessages.length,
              itemBuilder: (context, index) {
                final message = chatState.currentMessages[index];
                return _MessageBubble(
                  message: message,
                  isSpeaking: _isSpeaking && _currentlySpeakingText == message.text,
                  onPlayPause: () => _toggleSpeak(message.text),
                  onFastPlay: () => _speakFast(message.text),
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

  Widget _buildHistoryDrawer(ChatState chatState) {
    return Drawer(
      backgroundColor: AuraColors.abyssalGrey,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Historique Discussions", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: chatState.history.isEmpty
                  ? const Center(child: Text("Aucun historique", style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      itemCount: chatState.history.length,
                      itemBuilder: (context, index) {
                        final session = chatState.history[index];
                        final isSelected = session.id == chatState.activeSessionId;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: AuraColors.electricCyan.withOpacity(0.1),
                          title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSelected ? AuraColors.electricCyan : Colors.white70)),
                          subtitle: Text(DateFormat('dd/MM HH:mm').format(session.updatedAt), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: AuraColors.softCoral, size: 20),
                            onPressed: () => ref.read(chatProvider.notifier).deleteSession(session.id),
                          ),
                          onTap: () {
                            ref.read(chatProvider.notifier).loadSession(session.id);
                            Navigator.pop(context);
                            _scrollToBottom();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.add_a_photo, color: AuraColors.electricCyan),
                onPressed: _showImageSourceDialog,
                padding: const EdgeInsets.only(bottom: 8),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? AuraColors.softCoral : AuraColors.electricCyan),
                      onPressed: _listen,
                    ),
                    hintText: "Besoin d'aide ?",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                child: CircleAvatar(
                  backgroundColor: AuraColors.electricCyan,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _handleSend,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  final ChatMessage message;
  final bool isSpeaking;
  final VoidCallback onPlayPause;
  final VoidCallback onFastPlay;

  const _MessageBubble({
    required this.message, 
    required this.isSpeaking,
    required this.onPlayPause,
    required this.onFastPlay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == MessageRole.user;
    final user = ref.watch(userProvider);
    final userName = user?.name ?? 'Moi';
    final userAvatar = user?.avatarUrl;

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
                    color: isUser ? Colors.white.withOpacity(0.05) : AuraColors.abyssalGrey,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 20),
                    ),
                    border: isUser ? Border.all(color: AuraColors.electricCyan.withOpacity(0.5)) : Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("LAURA", style: TextStyle(color: AuraColors.mintNeon, fontSize: 10, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: onPlayPause,
                              onLongPress: onFastPlay,
                              child: Icon(
                                isSpeaking ? Icons.pause_circle_filled : Icons.volume_up, 
                                size: 28, 
                                color: AuraColors.electricCyan
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (isUser) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(userName.toUpperCase(), style: const TextStyle(color: AuraColors.mintNeon, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      MarkdownBody(
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: Colors.white, fontSize: 14),
                          strong: const TextStyle(color: AuraColors.mintNeon, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AuraColors.abyssalGrey,
                  backgroundImage: userAvatar != null 
                      ? NetworkImage(userAvatar) 
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

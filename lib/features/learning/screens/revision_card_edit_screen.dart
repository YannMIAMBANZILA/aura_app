import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../config/theme.dart';
import '../../../models/revision_card.dart';
import '../providers/revision_card_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevisionCardEditScreen extends ConsumerStatefulWidget {
  final String subject;
  final String chapter;
  final String initialContent;

  const RevisionCardEditScreen({
    super.key,
    required this.subject,
    required this.chapter,
    required this.initialContent,
  });

  @override
  ConsumerState<RevisionCardEditScreen> createState() => _RevisionCardEditScreenState();
}

class _RevisionCardEditScreenState extends ConsumerState<RevisionCardEditScreen> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connecte-toi pour sauvegarder tes fiches !")),
      );
      return;
    }

    final card = RevisionCard(
      userId: user.id,
      subject: widget.subject,
      chapter: widget.chapter,
      content: _controller.text,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(revisionCardProvider.notifier).saveCard(card);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fiche sauvegardée avec succès ! ✨")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la sauvegarde : $e")),
        );
      }
    }
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(widget.chapter.toUpperCase(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text("Matière : ${widget.subject}", style: const pw.TextStyle(fontSize: 14)),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(_controller.text), // Simplifié pour l'export, markdown direct
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _shareCard() async {
    final text = "Check ma fiche de révision AURA sur '${widget.chapter}' (${widget.subject}) !\n\n${_controller.text}";
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MA FICHE", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.visibility : Icons.edit, color: AuraColors.electricCyan),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: AuraColors.mintNeon),
            onPressed: _saveCard,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isEditing
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Rédige ta fiche ici...",
                      ),
                    ),
                  )
                : Markdown(
                    data: _controller.text,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                      h1: GoogleFonts.spaceGrotesk(color: AuraColors.electricCyan, fontWeight: FontWeight.bold),
                      h2: GoogleFonts.spaceGrotesk(color: AuraColors.mintNeon, fontWeight: FontWeight.bold),
                      strong: const TextStyle(color: AuraColors.mintNeon),
                    ),
                  ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AuraColors.abyssalGrey,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _shareCard,
              icon: const Icon(Icons.share),
              label: const Text("PARTAGER"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AuraColors.electricCyan.withOpacity(0.1),
                foregroundColor: AuraColors.electricCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

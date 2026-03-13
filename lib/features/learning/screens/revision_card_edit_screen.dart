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
    
    final fontBold = await PdfGoogleFonts.spaceGroteskBold();
    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontMedium = await PdfGoogleFonts.interMedium();

    // Palette Écoprint (Fond clair)
    const pdfPrimary = PdfColor.fromInt(0xFF0891B2); // Cyan plus sombre pour lecture sur blanc
    const pdfSecondary = PdfColor.fromInt(0xFF059669); // Emeraude/Menthe sombre
    const pdfText = PdfColor.fromInt(0xFF1E293B); // Bleu ardoise très sombre
    const pdfLightBg = PdfColor.fromInt(0xFFF8FAFC); // Fond de bloc très léger
    const pdfBorder = PdfColor.fromInt(0xFFE2E8F0); // Bordures discrètes

    pdf.addPage(
      pw.Page( // Passage en Page simple (vs MultiPage) pour inciter au format fiche
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        build: (pw.Context context) {
          final rawText = _controller.text;
          
          // Nettoyage et split des lignes
          final lines = rawText.split('\n');
          final List<pw.Widget> mainContent = [];

          for (var line in lines) {
            var trimmed = line.trim();
            if (trimmed.isEmpty) continue;

            // Nettoyage des résidus de mise en forme MD (**bold**)
            trimmed = trimmed.replaceAll('**', '').replaceAll('__', '');

            // TITRE PRINCIPAL (#)
            if (trimmed.startsWith('# ')) {
              mainContent.add(pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
                child: pw.Text(
                  trimmed.substring(2).toUpperCase(),
                  style: pw.TextStyle(font: fontBold, fontSize: 18, color: pdfPrimary),
                ),
              ));
              mainContent.add(pw.Container(height: 1, color: pdfPrimary, margin: const pw.EdgeInsets.only(bottom: 10)));
            } 
            // BLOC DE NOTION (###)
            else if (trimmed.startsWith('### ')) {
              mainContent.add(pw.Container(
                margin: const pw.EdgeInsets.only(top: 8, bottom: 4),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: pdfLightBg,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: pdfBorder),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      trimmed.substring(4),
                      style: pw.TextStyle(font: fontBold, fontSize: 13, color: pdfPrimary),
                    ),
                  ],
                ),
              ));
            }
            // SOUS-TITRE (##)
            else if (trimmed.startsWith('## ')) {
              mainContent.add(pw.Padding(
                padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
                child: pw.Text(
                  trimmed.substring(3),
                  style: pw.TextStyle(font: fontBold, fontSize: 14, color: pdfSecondary),
                ),
              ));
            }
            // LISTES (- ou *)
            else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
              mainContent.add(pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 4, right: 6),
                      width: 4, height: 4,
                      decoration: const pw.BoxDecoration(color: pdfPrimary, shape: pw.BoxShape.circle),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        trimmed.substring(2),
                        style: pw.TextStyle(font: fontRegular, color: pdfText, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ));
            }
            // TEXTE STANDARD
            else {
              mainContent.add(pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Text(
                  trimmed,
                  style: pw.TextStyle(font: fontRegular, color: pdfText, fontSize: 11, lineSpacing: 1.5),
                  textAlign: pw.TextAlign.justify,
                ),
              ));
            }
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER COMPACT
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(widget.chapter.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 22, color: pdfText)),
                      pw.Text("Fiche de révision • Aura App", style: pw.TextStyle(font: fontRegular, fontSize: 10, color: pdfPrimary)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: pdfPrimary),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(widget.subject, style: pw.TextStyle(font: fontBold, fontSize: 12, color: pdfPrimary)),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // CONTENU PRINCIPAL
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: mainContent,
                ),
              ),

              // FOOTER
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(top: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: pdfBorder)),
                ),
                child: pw.Text("Généré par Laura | www.aura-app.edu", style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey500)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Fiche_Aura_${widget.chapter.replaceAll(' ', '_')}',
    );
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

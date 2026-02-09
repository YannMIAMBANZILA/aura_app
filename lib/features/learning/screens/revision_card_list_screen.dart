import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../models/revision_card.dart';
import '../providers/revision_card_provider.dart';
import 'revision_card_edit_screen.dart';
import 'package:intl/intl.dart';

class RevisionCardListScreen extends ConsumerStatefulWidget {
  const RevisionCardListScreen({super.key});

  @override
  ConsumerState<RevisionCardListScreen> createState() => _RevisionCardListScreenState();
}

class _RevisionCardListScreenState extends ConsumerState<RevisionCardListScreen> {
  String _sortBy = 'date'; // 'date' or 'subject'

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(revisionCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("MES FICHES", style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AuraColors.electricCyan),
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text("Trier par date")),
              const PopupMenuItem(value: 'subject', child: Text("Trier par matière")),
            ],
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AuraColors.electricCyan)),
        error: (err, stack) => Center(child: Text("Erreur : $err")),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notes, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text("Tu n'as pas encore de fiches.", style: GoogleFonts.inter(color: Colors.white54)),
                ],
              ),
            );
          }

          final sortedCards = List<RevisionCard>.from(cards);
          if (_sortBy == 'subject') {
            sortedCards.sort((a, b) => a.subject.compareTo(b.subject));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedCards.length,
            itemBuilder: (context, index) {
              final card = sortedCards[index];
              return _buildCardItem(card);
            },
          );
        },
      ),
    );
  }

  Widget _buildCardItem(RevisionCard card) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RevisionCardEditScreen(
                subject: card.subject,
                chapter: card.chapter,
                initialContent: card.content,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuraColors.abyssalGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AuraColors.electricCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: AuraColors.electricCyan),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.chapter,
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "${card.subject} • ${DateFormat('dd MMM yyyy').format(card.createdAt)}",
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}

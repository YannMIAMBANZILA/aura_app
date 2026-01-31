import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionReviewScreen extends StatelessWidget {
  final List<dynamic> answers;
  final String dateStr;

  const SessionReviewScreen({
    super.key,
    required this.answers,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    // Calcul du score basé sur les index
    int correctCount = 0;
    for (var a in answers) {
      if (a['selected_answer_index'] == a['correct_answer_index']) {
        correctCount++;
      }
    }
    final totalCount = answers.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("ANALYSE DE SESSION", style: AuraTextStyles.subtitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          // En-tête résumé
          Container(
            padding: const EdgeInsets.all(16),
            color: AuraColors.abyssalGrey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: const TextStyle(color: Colors.white54)),
                Text(
                  "$correctCount/$totalCount Correctes",
                  style: TextStyle(
                    color: correctCount == totalCount ? AuraColors.mintNeon : AuraColors.electricCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: answers.length,
              itemBuilder: (context, index) {
                final item = answers[index];
                final questionText = item['question'] ?? "Question sans texte";
                final options = List<String>.from(item['options'] ?? []);
                final correctIndex = item['correct_answer_index'];
                final selectedIndex = item['selected_answer_index'];
                final explanation = item['explanation'];
                
                final isGlobalCorrect = correctIndex == selectedIndex;

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isGlobalCorrect ? AuraColors.mintNeon.withOpacity(0.3) : AuraColors.softCoral.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isGlobalCorrect ? Icons.check_circle : Icons.cancel,
                            color: isGlobalCorrect ? AuraColors.mintNeon : AuraColors.softCoral,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              questionText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Options
                      ...List.generate(options.length, (optIndex) {
                        return _buildOptionItem(
                          text: options[optIndex],
                          index: optIndex,
                          selectedIndex: selectedIndex,
                          correctIndex: correctIndex,
                        );
                      }),

                      // Hint / Explication (si erreur ou juste pour info)
                      if (!isGlobalCorrect && explanation != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AuraColors.abyssalGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Comprendre son erreur :", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      explanation,
                                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required String text,
    required int index,
    required int? selectedIndex,
    required int? correctIndex,
  }) {
    Color textColor = Colors.white70;
    Color borderColor = Colors.white10;
    Color backgroundColor = Colors.transparent;
    IconData? icon;

    // Logique de couleur
    if (index == correctIndex) {
      // C'est la bonne réponse -> Toujours Vert
      textColor = AuraColors.mintNeon;
      borderColor = AuraColors.mintNeon;
      backgroundColor = AuraColors.mintNeon.withOpacity(0.1);
      icon = Icons.check;
    } else if (index == selectedIndex) {
      // C'est la réponse choisie (et ce n'est pas la bonne, sinon couvert au-dessus)
      // -> Rouge
      textColor = AuraColors.softCoral;
      borderColor = AuraColors.softCoral;
      backgroundColor = AuraColors.softCoral.withOpacity(0.1);
      icon = Icons.close;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: (index == selectedIndex || index == correctIndex) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: textColor, size: 16),
          ]
        ],
      ),
    );
  }
}

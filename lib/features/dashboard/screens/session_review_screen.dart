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
    // Calcul rapide du score pour le header
    final correctCount = answers.where((a) => a['is_correct'] == true).length;
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
                final isCorrect = item['is_correct'] == true;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect ? AuraColors.mintNeon.withOpacity(0.3) : AuraColors.softCoral.withOpacity(0.3),
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
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? AuraColors.mintNeon : AuraColors.softCoral,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['question_text'] ?? "Question inconnue",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Réponses
                      if (isCorrect) ...[
                        _buildAnswerRow("Ta réponse :", item['user_answer'], AuraColors.mintNeon),
                      ] else ...[
                        _buildAnswerRow("Ta réponse :", item['user_answer'], AuraColors.softCoral),
                        const SizedBox(height: 8),
                        _buildAnswerRow("Correction :", item['correct_answer'], AuraColors.mintNeon),
                        
                        // Explication
                        if (item['explanation'] != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AuraColors.abyssalGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['explanation'],
                                    style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]
                      ]
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

  Widget _buildAnswerRow(String label, String? value, Color color) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? "?",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';

class FlashcardWidget extends StatelessWidget {
  final String question;
  final String subject;

  const FlashcardWidget({
    super.key,
    required this.question,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AuraColors.abyssalGrey,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AuraColors.electricCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge Matière
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AuraColors.electricCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subject.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AuraColors.electricCyan,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // La Question
          Text(
            question,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 24,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
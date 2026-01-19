class Question {
  final String subject;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String hint; // L'indice que Laura donnera

  Question({
    required this.subject,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.hint,
  });
}
class Question {
  final String id;
  final String subject;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String hint;

  Question({
    required this.id,
    required this.subject,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.hint,
  });

  // Transforme les données de Supabase en Question
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      subject: map['subject'] ?? 'GÉNÉRAL',
      text: map['question_text'] ?? '',
      // Supabase renvoie une List<dynamic>, il faut forcer en List<String>
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correct_index'] ?? 0,
      hint: map['hint'] ?? 'Concentre-toi !',
    );
  }
}
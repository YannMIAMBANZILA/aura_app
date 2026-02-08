class SummaryPart {
  final String title;
  final String content;

  SummaryPart({required this.title, required this.content});

  factory SummaryPart.fromJson(Map<String, dynamic> json) {
    return SummaryPart(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class LessonQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  LessonQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory LessonQuizQuestion.fromJson(Map<String, dynamic> json) {
    return LessonQuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correct_index'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class LessonContent {
  final String description;
  final List<SummaryPart> fullSummary;
  final String example;
  final String proPointCareer;
  final String proPointApplication;
  final List<String> keyPoints;
  final List<LessonQuizQuestion> quizQuestions;

  LessonContent({
    required this.description,
    required this.fullSummary,
    required this.example,
    required this.proPointCareer,
    required this.proPointApplication,
    required this.keyPoints,
    required this.quizQuestions,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      description: json['description'] ?? '',
      fullSummary: (json['full_summary'] as List?)
              ?.map((e) => SummaryPart.fromJson(e))
              .toList() ??
          [],
      example: json['example'] ?? '',
      proPointCareer: json['pro_point_career'] ?? '',
      proPointApplication: json['pro_point_application'] ?? '',
      keyPoints: List<String>.from(json['key_points'] ?? []),
      quizQuestions: (json['quiz_questions'] as List?)
              ?.map((e) => LessonQuizQuestion.fromJson(e))
              .toList() ??
          [],
    );
  }
}

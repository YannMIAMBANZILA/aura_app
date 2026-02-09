class RevisionCard {
  final String? id;
  final String userId;
  final String subject;
  final String chapter;
  final String content;
  final DateTime createdAt;

  RevisionCard({
    this.id,
    required this.userId,
    required this.subject,
    required this.chapter,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'subject': subject,
      'chapter': chapter,
      'content': content,
    };
  }

  factory RevisionCard.fromMap(Map<String, dynamic> map) {
    return RevisionCard(
      id: map['id'],
      userId: map['user_id'],
      subject: map['subject'],
      chapter: map['chapter'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  RevisionCard copyWith({
    String? content,
  }) {
    return RevisionCard(
      id: id,
      userId: userId,
      subject: subject,
      chapter: chapter,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }
}

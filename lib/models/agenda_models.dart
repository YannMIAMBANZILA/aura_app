// models/agenda_models.dart
// Model pour l'agenda

class TimetableEntry {
  final String? id;
  final String? userId;
  final int dayOfWeek; // 1 = Lundi, 5 = Vendredi
  final String startTime; // Format 'HH:mm'
  final String endTime;
  final String subject;

  TimetableEntry({
    this.id,
    this.userId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.subject,
  });

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'],
      userId: map['user_id'],
      dayOfWeek: map['day_of_week'],
      startTime: map['start_time'].toString().substring(0, 5), // Garde juste HH:mm
      endTime: map['end_time'].toString().substring(0, 5),
      subject: map['subject'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': '$startTime:00', // Format attendu par Postgres
      'end_time': '$endTime:00',
      'subject': subject,
    };
  }
}

class DeadlineTask {
  final String? id;
  final String? userId;
  final DateTime dueDate;
  final String subject;
  final String taskType; // 'DS' ou 'DEVOIR'
  final String? description;
  final bool isCompleted;

  DeadlineTask({
    this.id,
    this.userId,
    required this.dueDate,
    required this.subject,
    required this.taskType,
    this.description,
    this.isCompleted = false,
  });

  factory DeadlineTask.fromMap(Map<String, dynamic> map) {
    return DeadlineTask(
      id: map['id'],
      userId: map['user_id'],
      dueDate: DateTime.parse(map['due_date']),
      subject: map['subject'],
      taskType: map['task_type'],
      description: map['description'],
      isCompleted: map['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'due_date': dueDate.toIso8601String().split('T')[0], // Format YYYY-MM-DD
      'subject': subject,
      'task_type': taskType,
      'description': description,
      'is_completed': isCompleted,
    };
  }
}
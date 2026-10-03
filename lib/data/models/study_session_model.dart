import 'dart:convert';

/// Represents a completed focus/study session recorded after Pomodoro ends.
class StudySession {
  final String id;
  final String userId;
  final String courseId;
  final String topicId;
  final DateTime startTime;
  final DateTime endTime;
  final int productivityRating; // 1–5
  final String notes;
  final bool wasPomodoro;

  StudySession({
    required this.id,
    this.userId = '',
    required this.courseId,
    this.topicId = '',
    required this.startTime,
    required this.endTime,
    this.productivityRating = 3,
    this.notes = '',
    this.wasPomodoro = false,
  });

  double get durationHours =>
      endTime.difference(startTime).inMinutes / 60.0;

  int get durationMinutes => endTime.difference(startTime).inMinutes;

  StudySession copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? topicId,
    DateTime? startTime,
    DateTime? endTime,
    int? productivityRating,
    String? notes,
    bool? wasPomodoro,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      topicId: topicId ?? this.topicId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      productivityRating: productivityRating ?? this.productivityRating,
      notes: notes ?? this.notes,
      wasPomodoro: wasPomodoro ?? this.wasPomodoro,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'course_id': courseId,
        'topic_id': topicId,
        'start_time': startTime.millisecondsSinceEpoch,
        'end_time': endTime.millisecondsSinceEpoch,
        'productivity_rating': productivityRating,
        'notes': notes,
        'was_pomodoro': wasPomodoro ? 1 : 0,
      };

  factory StudySession.fromMap(Map<String, dynamic> map) => StudySession(
        id: map['id'] as String,
        userId: (map['user_id'] ?? '') as String,
        courseId: (map['course_id'] ?? '') as String,
        topicId: (map['topic_id'] ?? '') as String,
        startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
        endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
        productivityRating: (map['productivity_rating'] ?? 3) as int,
        notes: (map['notes'] ?? '') as String,
        wasPomodoro:
            map['was_pomodoro'] == 1 || map['was_pomodoro'] == true,
      );

  String toJson() => jsonEncode(toMap());
  factory StudySession.fromJson(String source) =>
      StudySession.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

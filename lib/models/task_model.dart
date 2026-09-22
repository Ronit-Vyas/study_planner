import 'dart:convert';

class StudyTask {
  final String id;
  final String userId;
  final String courseId;
  final String topicId;
  final DateTime date;
  final double duration;
  bool completed;

  StudyTask({
    required this.id,
    this.userId = '',
    required this.courseId,
    required this.topicId,
    required this.date,
    required this.duration,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'topic_id': topicId,
      'date': date.millisecondsSinceEpoch,
      'duration': duration,
      'completed': completed ? 1 : 0,
    };
  }

  factory StudyTask.fromMap(Map<String, dynamic> map) {
    return StudyTask(
      id: map['id'] as String,
      userId: (map['user_id'] ?? '') as String,
      courseId: map['course_id'] as String,
      topicId: map['topic_id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      duration: (map['duration'] as num).toDouble(),
      completed: map['completed'] == 1 || map['completed'] == true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory StudyTask.fromJson(String source) =>
      StudyTask.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

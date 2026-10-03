import 'dart:convert';

class StudyNote {
  final String id;
  final String userId;
  final String? courseId;
  final String? topicId;
  final String? examId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyNote({
    required this.id,
    this.userId = '',
    this.courseId,
    this.topicId,
    this.examId,
    required this.title,
    this.content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  StudyNote copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? topicId,
    String? examId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyNote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      topicId: topicId ?? this.topicId,
      examId: examId ?? this.examId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'course_id': courseId,
        'topic_id': topicId,
        'exam_id': examId,
        'title': title,
        'content': content,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory StudyNote.fromMap(Map<String, dynamic> map) => StudyNote(
        id: map['id'] as String,
        userId: (map['user_id'] ?? '') as String,
        courseId: map['course_id'] as String?,
        topicId: map['topic_id'] as String?,
        examId: map['exam_id'] as String?,
        title: map['title'] as String,
        content: (map['content'] ?? '') as String,
        createdAt: map['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
            : DateTime.now(),
        updatedAt: map['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
            : DateTime.now(),
      );

  String toJson() => jsonEncode(toMap());
  factory StudyNote.fromJson(String source) =>
      StudyNote.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

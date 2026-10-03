import 'dart:convert';

class Exam {
  final String id;
  final String userId;
  final String courseId;
  final String name;
  final DateTime examDate;
  final String syllabus;
  final double targetScore;
  final String notes;
  final DateTime createdAt;

  Exam({
    required this.id,
    this.userId = '',
    required this.courseId,
    required this.name,
    required this.examDate,
    this.syllabus = '',
    this.targetScore = 0,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get daysUntilExam => examDate.difference(DateTime.now()).inDays;
  bool get isPast => examDate.isBefore(DateTime.now());

  Exam copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? name,
    DateTime? examDate,
    String? syllabus,
    double? targetScore,
    String? notes,
    DateTime? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      examDate: examDate ?? this.examDate,
      syllabus: syllabus ?? this.syllabus,
      targetScore: targetScore ?? this.targetScore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'course_id': courseId,
        'name': name,
        'exam_date': examDate.millisecondsSinceEpoch,
        'syllabus': syllabus,
        'target_score': targetScore,
        'notes': notes,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Exam.fromMap(Map<String, dynamic> map) => Exam(
        id: map['id'] as String,
        userId: (map['user_id'] ?? '') as String,
        courseId: map['course_id'] as String,
        name: map['name'] as String,
        examDate: DateTime.fromMillisecondsSinceEpoch(map['exam_date'] as int),
        syllabus: (map['syllabus'] ?? '') as String,
        targetScore: ((map['target_score'] ?? 0) as num).toDouble(),
        notes: (map['notes'] ?? '') as String,
        createdAt: map['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
            : DateTime.now(),
      );

  String toJson() => jsonEncode(toMap());
  factory Exam.fromJson(String source) =>
      Exam.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

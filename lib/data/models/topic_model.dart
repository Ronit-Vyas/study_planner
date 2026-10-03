import 'dart:convert';

enum TopicStatus { notStarted, inProgress, completed }

class Topic {
  final String id;
  final String courseId;
  final String name;
  final double estimatedHours;
  final TopicStatus status;
  final String priority; // low / medium / high
  final DateTime? deadline;
  final String notes;
  final int difficulty; // 1=easy, 2=medium, 3=hard
  final DateTime createdAt;

  Topic({
    required this.id,
    required this.courseId,
    required this.name,
    this.estimatedHours = 1.0,
    this.status = TopicStatus.notStarted,
    this.priority = 'medium',
    this.deadline,
    this.notes = '',
    this.difficulty = 2,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Topic copyWith({
    String? id,
    String? courseId,
    String? name,
    double? estimatedHours,
    TopicStatus? status,
    String? priority,
    DateTime? deadline,
    String? notes,
    int? difficulty,
    DateTime? createdAt,
  }) {
    return Topic(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCompleted => status == TopicStatus.completed;
  bool get isInProgress => status == TopicStatus.inProgress;
  bool get isNotStarted => status == TopicStatus.notStarted;

  String get statusLabel {
    switch (status) {
      case TopicStatus.notStarted:
        return 'Not Started';
      case TopicStatus.inProgress:
        return 'In Progress';
      case TopicStatus.completed:
        return 'Completed';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'name': name,
      'estimated_hours': estimatedHours,
      'status': status.index,
      'priority': priority,
      'deadline': deadline?.millisecondsSinceEpoch,
      'notes': notes,
      'difficulty': difficulty,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      name: map['name'] as String,
      estimatedHours: (map['estimated_hours'] as num).toDouble(),
      status: TopicStatus.values[(map['status'] ?? 0) as int],
      priority: (map['priority'] ?? 'medium') as String,
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int)
          : null,
      notes: (map['notes'] ?? '') as String,
      difficulty: (map['difficulty'] ?? 2) as int,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Topic.fromJson(String source) =>
      Topic.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

import 'dart:convert';

class Course {
  final String id;
  final String userId;
  final String name;
  final String description;
  final DateTime deadline;
  final String priority;
  final double estimatedHours;

  Course({
    required this.id,
    this.userId = '',
    required this.name,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.estimatedHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'deadline': deadline.millisecondsSinceEpoch,
      'priority': priority,
      'estimated_hours': estimatedHours,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      userId: (map['user_id'] ?? '') as String,
      name: map['name'] as String,
      description: (map['description'] ?? '') as String,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int),
      priority: (map['priority'] ?? 'Medium') as String,
      estimatedHours: (map['estimated_hours'] as num).toDouble(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Course.fromJson(String source) =>
      Course.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
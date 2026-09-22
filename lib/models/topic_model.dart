import 'dart:convert';

class Topic {
  final String id;
  final String courseId;
  final String name;
  final double estimatedHours;

  Topic({
    required this.id,
    required this.courseId,
    required this.name,
    required this.estimatedHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'name': name,
      'estimated_hours': estimatedHours,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      name: map['name'] as String,
      estimatedHours: (map['estimated_hours'] as num).toDouble(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Topic.fromJson(String source) =>
      Topic.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
import 'dart:convert';
import 'package:flutter/material.dart';

enum CourseDifficulty { easy, medium, hard }
enum CourseStatus { active, archived }

class Course {
  final String id;
  final String userId;
  final String name;
  final String description;
  final DateTime deadline;
  final String priority; // low / medium / high / urgent
  final double estimatedHours;
  final double completedHours;
  final int colorIndex; // index into AppColors.subjectPalette
  final CourseDifficulty difficulty;
  final CourseStatus status;
  final DateTime createdAt;

  Course({
    required this.id,
    this.userId = '',
    required this.name,
    this.description = '',
    required this.deadline,
    this.priority = 'medium',
    required this.estimatedHours,
    this.completedHours = 0,
    this.colorIndex = 0,
    this.difficulty = CourseDifficulty.medium,
    this.status = CourseStatus.active,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Course copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? deadline,
    String? priority,
    double? estimatedHours,
    double? completedHours,
    int? colorIndex,
    CourseDifficulty? difficulty,
    CourseStatus? status,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      completedHours: completedHours ?? this.completedHours,
      colorIndex: colorIndex ?? this.colorIndex,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'deadline': deadline.millisecondsSinceEpoch,
      'priority': priority,
      'estimated_hours': estimatedHours,
      'completed_hours': completedHours,
      'color_index': colorIndex,
      'difficulty': difficulty.index,
      'status': status.index,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      userId: (map['user_id'] ?? '') as String,
      name: map['name'] as String,
      description: (map['description'] ?? '') as String,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int),
      priority: (map['priority'] ?? 'medium') as String,
      estimatedHours: (map['estimated_hours'] as num).toDouble(),
      completedHours: ((map['completed_hours'] ?? 0) as num).toDouble(),
      colorIndex: (map['color_index'] ?? 0) as int,
      difficulty: CourseDifficulty.values[(map['difficulty'] ?? 1) as int],
      status: CourseStatus.values[(map['status'] ?? 0) as int],
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Course.fromJson(String source) =>
      Course.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Progress 0.0 – 1.0 based on completed / estimated hours.
  double get progress =>
      estimatedHours > 0 ? (completedHours / estimatedHours).clamp(0.0, 1.0) : 0.0;

  /// Convenience priority level as int for sorting.
  int get priorityValue {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 2;
    }
  }

  /// Days remaining until deadline (negative means past deadline).
  int get daysUntilDeadline =>
      deadline.difference(DateTime.now()).inDays;

  bool get isArchived => status == CourseStatus.archived;
  bool get isActive => status == CourseStatus.active;

  // Colour from palette
  Color get color {
    // Import guard: this list mirrors AppColors.subjectPalette
    const palette = [
      Color(0xFF6C63FF),
      Color(0xFFF43F5E),
      Color(0xFF06B6D4),
      Color(0xFF22C55E),
      Color(0xFFF97316),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFFEC4899),
      Color(0xFF3B82F6),
    ];
    return palette[colorIndex.clamp(0, palette.length - 1)];
  }

  int get colorValue => color.toARGB32();
}

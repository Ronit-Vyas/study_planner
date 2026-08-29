class Course {
  final String id;
  final String name;
  final String description;
  final DateTime deadline;
  final String priority;
  final double estimatedHours;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.estimatedHours,
  });
}
class StudyTask {
  final String id;
  final String courseId;
  final String courseName;
  final String title;
  final DateTime date;
  final double duration;
  final String priority;

  bool completed;

  StudyTask({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.date,
    required this.duration,
    required this.priority,
    this.completed = false,
  });
}
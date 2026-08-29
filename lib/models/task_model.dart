class StudyTask {
  final String id;

  final String courseId;
  final String topicId;

  final DateTime date;

  final double duration;

  bool completed;

  StudyTask({
    required this.id,
    required this.courseId,
    required this.topicId,
    required this.date,
    required this.duration,
    this.completed = false,
  });
}

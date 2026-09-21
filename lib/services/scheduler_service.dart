import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/task_model.dart';

class SchedulerService {
  static List<StudyTask> generateSchedule({
    required List<Course> courses,
    required List<Topic> topics,
    required double hoursPerDay,
  }) {
    final List<StudyTask> generatedTasks = [];

    if (hoursPerDay <= 0) {
      return generatedTasks;
    }

    // Sort courses by priority and deadline.
    final sortedCourses = [...courses];

    sortedCourses.sort((a, b) {
      final priorityComparison =
      _priorityValue(b.priority)
          .compareTo(_priorityValue(a.priority));

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      return a.deadline.compareTo(b.deadline);
    });

    for (final course in sortedCourses) {
      final courseTopics = topics
          .where((topic) => topic.courseId == course.id)
          .toList();

      // Higher priority topics are scheduled first.
      for (final topic in courseTopics) {
        double remainingHours = topic.estimatedHours;

        DateTime currentDate = DateTime.now();

        while (
        remainingHours > 0 &&
            !currentDate.isAfter(course.deadline)) {
          final double todayHours =
          remainingHours > hoursPerDay
              ? hoursPerDay
              : remainingHours;

          generatedTasks.add(
            StudyTask(
              id: '${topic.id}_${currentDate.millisecondsSinceEpoch}',
              courseId: course.id,
              topicId: topic.id,
              date: currentDate,
              duration: todayHours,
            ),
          );

          remainingHours -= todayHours;

          currentDate = currentDate.add(
            const Duration(days: 1),
          );
        }
      }
    }

    return generatedTasks;
  }

  static int _priorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;

      case 'medium':
        return 2;

      case 'low':
        return 1;

      default:
        return 1;
    }
  }
}
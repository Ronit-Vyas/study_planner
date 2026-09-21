import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/task_model.dart';

class FirestoreService {
  static final List<Course> courses = [];

  static final List<Topic> topics = [];

  static final List<StudyTask> tasks = [];

  // ---------------- COURSE ----------------

  static void addCourse(Course course) {
    courses.add(course);
  }

  static List<Course> getCourses() {
    return courses;
  }

  // ---------------- TOPIC ----------------

  static void addTopic(Topic topic) {
    topics.add(topic);
  }

  static List<Topic> getTopicsForCourse(String courseId) {
    return topics
        .where((topic) => topic.courseId == courseId)
        .toList();
  }

  // ---------------- TASK ----------------

  static void addTask(StudyTask task) {
    tasks.add(task);
  }

  static List<StudyTask> getTasks() {
    return tasks;
  }

  static List<StudyTask> getTasksForDate(DateTime date) {
    return tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  static List<StudyTask> getTasksForTopic(String topicId) {
    return tasks
        .where((task) => task.topicId == topicId)
        .toList();
  }
}
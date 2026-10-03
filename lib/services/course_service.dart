import '../data/models/course_model.dart';
import '../data/models/topic_model.dart';
import '../data/models/task_model.dart';
import 'local_storage_service.dart';
import 'scheduler_service.dart';

class CourseService {
  static Future<List<Course>> getAllCourses({String? userId}) async {
    return await LocalStorageService.getCourses(userId: userId);
  }

  static Future<Course?> getCourseById(String id, {String? userId}) async {
    return await LocalStorageService.getCourseById(id, userId: userId);
  }

  static Future<void> addCourse(Course course, {String? userId}) async {
    await LocalStorageService.addCourse(course, userId: userId);
  }

  static Future<void> updateCourse(Course course, {String? userId}) async {
    await LocalStorageService.updateCourse(course, userId: userId);
  }

  static Future<void> deleteCourse(String courseId, {String? userId}) async {
    await LocalStorageService.deleteCourse(courseId, userId: userId);
  }

  // TOPICS
  static Future<List<Topic>> getTopicsForCourse(
    String courseId, {
    String? userId,
  }) async {
    return await LocalStorageService.getTopicsForCourse(
      courseId,
      userId: userId,
    );
  }

  static Future<Topic?> getTopicById(String id, {String? userId}) async {
    return await LocalStorageService.getTopicById(id, userId: userId);
  }

  static Future<void> addTopic(Topic topic, {String? userId}) async {
    await LocalStorageService.addTopic(topic, userId: userId);
  }

  static Future<void> deleteTopic(String topicId, {String? userId}) async {
    await LocalStorageService.deleteTopic(topicId, userId: userId);
  }

  // TASKS
  static Future<List<StudyTask>> getAllTasks({String? userId}) async {
    return await LocalStorageService.getAllTasks(userId: userId);
  }

  static Future<List<StudyTask>> getTasksForDate(
    DateTime date, {
    String? userId,
  }) async {
    return await LocalStorageService.getTasksForDate(date, userId: userId);
  }

  static Future<void> saveTasks(
    List<StudyTask> tasks, {
    String? userId,
  }) async {
    await LocalStorageService.saveTasks(tasks, userId: userId);
  }

  static Future<void> updateTask(StudyTask task, {String? userId}) async {
    await LocalStorageService.updateTask(task, userId: userId);
  }

  static Future<void> toggleTaskCompleted(
    String taskId, {
    String? userId,
  }) async {
    await LocalStorageService.toggleTaskCompleted(taskId, userId: userId);
  }

  static Future<void> deleteTask(String taskId, {String? userId}) async {
    await LocalStorageService.deleteTask(taskId, userId: userId);
  }

  // CONVENIENCE & STREAMLINED WORKFLOWS
  static Future<int> generateAndSaveSchedule({String? userId}) async {
    final dailyHours = await LocalStorageService.getDailyStudyHours(userId: userId);
    final courses = await getAllCourses(userId: userId);
    final allTopics = await LocalStorageService.getAllTopics(userId: userId);
    final tasks = SchedulerService.generateSchedule(
      courses: courses,
      topics: allTopics,
      hoursPerDay: dailyHours,
    );
    await saveTasks(tasks, userId: userId);
    return tasks.length;
  }

  static Future<int> createCourseWithTopicsAndSchedule({
    required Course course,
    required List<Topic> topics,
    bool autoGenerateSchedule = true,
    String? userId,
  }) async {
    await addCourse(course, userId: userId);
    for (final topic in topics) {
      await addTopic(topic, userId: userId);
    }
    if (autoGenerateSchedule && topics.isNotEmpty) {
      return await generateAndSaveSchedule(userId: userId);
    }
    return 0;
  }
}
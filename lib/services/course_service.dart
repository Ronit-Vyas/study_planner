import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/task_model.dart';
import 'local_storage_service.dart';


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

  //  TOPICS

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
}
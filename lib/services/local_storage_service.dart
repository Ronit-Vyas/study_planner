import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/task_model.dart';
import 'auth_service.dart';


class LocalStorageService {
  static String _resolveUserId(String? userId) {
    if (userId != null && userId.isNotEmpty) return userId;
    return AuthService.currentUser?.id ?? 'local_user';
  }

  static String _coursesKey(String? userId) =>
      'study_courses_${_resolveUserId(userId)}';
  static String _topicsKey(String? userId) =>
      'study_topics_${_resolveUserId(userId)}';
  static String _tasksKey(String? userId) =>
      'study_tasks_${_resolveUserId(userId)}';
  static String _dailyHoursKey(String? userId) =>
      'study_daily_hours_${_resolveUserId(userId)}';
  static String _notifEnabledKey(String? userId) =>
      'study_notif_enabled_${_resolveUserId(userId)}';
  static String _notifTimeKey(String? userId) =>
      'study_notif_time_${_resolveUserId(userId)}';


  static Future<List<Course>> getCourses({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_coursesKey(userId)) ?? [];

    final courses = jsonList
        .map((item) => Course.fromJson(item))
        .toList();

    // Sort by deadline ascending
    courses.sort((a, b) => a.deadline.compareTo(b.deadline));
    return courses;
  }

  static Future<Course?> getCourseById(String id, {String? userId}) async {
    final courses = await getCourses(userId: userId);
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> addCourse(Course course, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCourses = await getCourses(userId: userId);

    final resolvedUserId = _resolveUserId(userId);
    final courseWithUser = Course(
      id: course.id,
      userId: resolvedUserId,
      name: course.name,
      description: course.description,
      deadline: course.deadline,
      priority: course.priority,
      estimatedHours: course.estimatedHours,
    );

    // Remove existing if any, then append
    currentCourses.removeWhere((c) => c.id == course.id);
    currentCourses.add(courseWithUser);

    final stringList = currentCourses.map((c) => c.toJson()).toList();
    await prefs.setStringList(_coursesKey(userId), stringList);
  }

  static Future<void> updateCourse(Course course, {String? userId}) async {
    await addCourse(course, userId: userId);
  }

  static Future<void> deleteCourse(String courseId, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCourses = await getCourses(userId: userId);
    currentCourses.removeWhere((c) => c.id == courseId);

    final stringList = currentCourses.map((c) => c.toJson()).toList();
    await prefs.setStringList(_coursesKey(userId), stringList);

    // Also delete associated topics and tasks from local storage
    final currentTopics = await getAllTopics(userId: userId);
    final remainingTopics =
        currentTopics.where((t) => t.courseId != courseId).toList();
    await _saveTopicsList(remainingTopics, userId: userId);

    final currentTasks = await getAllTasks(userId: userId);
    final remainingTasks =
        currentTasks.where((t) => t.courseId != courseId).toList();
    await _saveTasksList(remainingTasks, userId: userId);
  }


  static Future<List<Topic>> getAllTopics({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_topicsKey(userId)) ?? [];
    return jsonList.map((item) => Topic.fromJson(item)).toList();
  }

  static Future<List<Topic>> getTopicsForCourse(
    String courseId, {
    String? userId,
  }) async {
    final allTopics = await getAllTopics(userId: userId);
    return allTopics.where((topic) => topic.courseId == courseId).toList();
  }

  static Future<Topic?> getTopicById(String id, {String? userId}) async {
    final allTopics = await getAllTopics(userId: userId);
    try {
      return allTopics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> addTopic(Topic topic, {String? userId}) async {
    final allTopics = await getAllTopics(userId: userId);
    allTopics.removeWhere((t) => t.id == topic.id);
    allTopics.add(topic);
    await _saveTopicsList(allTopics, userId: userId);
  }

  static Future<void> updateTopic(Topic topic, {String? userId}) async {
    await addTopic(topic, userId: userId);
  }

  static Future<void> deleteTopic(String topicId, {String? userId}) async {
    final allTopics = await getAllTopics(userId: userId);
    allTopics.removeWhere((t) => t.id == topicId);
    await _saveTopicsList(allTopics, userId: userId);

    // Also clean up associated tasks
    final currentTasks = await getAllTasks(userId: userId);
    final remainingTasks =
        currentTasks.where((t) => t.topicId != topicId).toList();
    await _saveTasksList(remainingTasks, userId: userId);
  }

  static Future<void> _saveTopicsList(
    List<Topic> topics, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = topics.map((t) => t.toJson()).toList();
    await prefs.setStringList(_topicsKey(userId), stringList);
  }

  // ===========================================================================
  // TASKS (Stored Locally On Device)
  // ===========================================================================

  static Future<List<StudyTask>> getAllTasks({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_tasksKey(userId)) ?? [];
    return jsonList.map((item) => StudyTask.fromJson(item)).toList();
  }

  static Future<List<StudyTask>> getTasksForDate(
    DateTime date, {
    String? userId,
  }) async {
    final tasks = await getAllTasks(userId: userId);
    return tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  static Future<void> saveTasks(
    List<StudyTask> tasks, {
    String? userId,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final tasksWithUser = tasks.map((t) {
      return StudyTask(
        id: t.id,
        userId: resolvedUserId,
        courseId: t.courseId,
        topicId: t.topicId,
        date: t.date,
        duration: t.duration,
        completed: t.completed,
      );
    }).toList();

    await _saveTasksList(tasksWithUser, userId: userId);
  }

  static Future<void> addTask(StudyTask task, {String? userId}) async {
    final allTasks = await getAllTasks(userId: userId);
    allTasks.removeWhere((t) => t.id == task.id);
    allTasks.add(task);
    await _saveTasksList(allTasks, userId: userId);
  }

  static Future<void> updateTask(StudyTask task, {String? userId}) async {
    await addTask(task, userId: userId);
  }

  static Future<void> toggleTaskCompleted(
    String taskId, {
    String? userId,
  }) async {
    final allTasks = await getAllTasks(userId: userId);
    for (final task in allTasks) {
      if (task.id == taskId) {
        task.completed = !task.completed;
        break;
      }
    }
    await _saveTasksList(allTasks, userId: userId);
  }

  static Future<void> deleteTask(String taskId, {String? userId}) async {
    final allTasks = await getAllTasks(userId: userId);
    allTasks.removeWhere((t) => t.id == taskId);
    await _saveTasksList(allTasks, userId: userId);
  }

  static Future<void> _saveTasksList(
    List<StudyTask> tasks, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_tasksKey(userId), stringList);
  }

    // PREFERENCES / SETTINGS (Daily Study Hours & Notifications)

  static Future<double> getDailyStudyHours({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_dailyHoursKey(userId)) ?? 3.0;
  }

  static Future<void> setDailyStudyHours(
    double hours, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_dailyHoursKey(userId), hours);
  }

  static Future<bool> getNotificationsEnabled({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifEnabledKey(userId)) ?? true;
  }

  static Future<void> setNotificationsEnabled(
    bool enabled, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifEnabledKey(userId), enabled);
  }

  static Future<String> getReminderTime({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notifTimeKey(userId)) ?? '09:00';
  }

  static Future<void> setReminderTime(
    String timeString, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notifTimeKey(userId), timeString);
  }
}

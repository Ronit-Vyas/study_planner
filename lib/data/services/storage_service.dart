import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/task_model.dart';
import '../models/exam_model.dart';
import '../models/note_model.dart';
import '../models/study_session_model.dart';

/// Central local-storage service.
/// All data is persisted in SharedPreferences as JSON strings,
/// namespaced by userId so multiple accounts work correctly.
class StorageService {
  // ── Key builders ──────────────────────────────────────────────────────────
  static String _key(String type, String userId) =>
      'sp_${type}_$userId';

  // ── COURSES ───────────────────────────────────────────────────────────────

  static Future<List<Course>> getCourses(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key('courses', userId)) ?? [];
    return list.map(Course.fromJson).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  static Future<Course?> getCourseById(String userId, String id) async {
    final courses = await getCourses(userId);
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCourse(String userId, Course course) async {
    final prefs = await SharedPreferences.getInstance();
    final courses = await getCourses(userId);
    courses.removeWhere((c) => c.id == course.id);
    courses.add(course.copyWith(userId: userId));
    await prefs.setStringList(
        _key('courses', userId), courses.map((c) => c.toJson()).toList());
  }

  static Future<void> deleteCourse(String userId, String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final courses = await getCourses(userId);
    courses.removeWhere((c) => c.id == courseId);
    await prefs.setStringList(
        _key('courses', userId), courses.map((c) => c.toJson()).toList());
    // cascade-delete topics, tasks, exams, notes
    await _deleteTopicsByCourse(userId, courseId);
    await _deleteTasksByCourse(userId, courseId);
    await _deleteExamsByCourse(userId, courseId);
    await _deleteNotesByCourse(userId, courseId);
  }

  // ── TOPICS ────────────────────────────────────────────────────────────────

  static Future<List<Topic>> getAllTopics(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key('topics', userId)) ?? [];
    return list.map(Topic.fromJson).toList();
  }

  static Future<List<Topic>> getTopicsForCourse(
      String userId, String courseId) async {
    final all = await getAllTopics(userId);
    return all.where((t) => t.courseId == courseId).toList();
  }

  static Future<Topic?> getTopicById(String userId, String id) async {
    final all = await getAllTopics(userId);
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveTopic(String userId, Topic topic) async {
    final prefs = await SharedPreferences.getInstance();
    final topics = await getAllTopics(userId);
    topics.removeWhere((t) => t.id == topic.id);
    topics.add(topic);
    await prefs.setStringList(
        _key('topics', userId), topics.map((t) => t.toJson()).toList());
  }

  static Future<void> deleteTopic(String userId, String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final topics = await getAllTopics(userId);
    topics.removeWhere((t) => t.id == topicId);
    await prefs.setStringList(
        _key('topics', userId), topics.map((t) => t.toJson()).toList());
    // cascade-delete tasks for this topic
    final tasks = await getAllTasks(userId);
    final remaining = tasks.where((t) => t.topicId != topicId).toList();
    await _saveAllTasks(userId, remaining);
  }

  static Future<void> _deleteTopicsByCourse(
      String userId, String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final topics = await getAllTopics(userId);
    final remaining = topics.where((t) => t.courseId != courseId).toList();
    await prefs.setStringList(
        _key('topics', userId), remaining.map((t) => t.toJson()).toList());
  }

  // ── TASKS ────────────────────────────────────────────────────────────────

  static Future<List<StudyTask>> getAllTasks(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key('tasks', userId)) ?? [];
    return list.map(StudyTask.fromJson).toList();
  }

  static Future<List<StudyTask>> getTasksForDate(
      String userId, DateTime date) async {
    final all = await getAllTasks(userId);
    return all.where((t) =>
        t.scheduledDate.year == date.year &&
        t.scheduledDate.month == date.month &&
        t.scheduledDate.day == date.day).toList();
  }

  static Future<List<StudyTask>> getTasksForCourse(
      String userId, String courseId) async {
    final all = await getAllTasks(userId);
    return all.where((t) => t.courseId == courseId).toList();
  }

  static Future<void> saveTask(String userId, StudyTask task) async {
    final all = await getAllTasks(userId);
    all.removeWhere((t) => t.id == task.id);
    all.add(task.copyWith(userId: userId));
    await _saveAllTasks(userId, all);
  }

  static Future<void> saveAllTasks(
      String userId, List<StudyTask> tasks) async {
    final tasksWithUser =
        tasks.map((t) => t.copyWith(userId: userId)).toList();
    await _saveAllTasks(userId, tasksWithUser);
  }

  static Future<void> _saveAllTasks(
      String userId, List<StudyTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key('tasks', userId), tasks.map((t) => t.toJson()).toList());
  }

  static Future<void> toggleTaskCompleted(String userId, String taskId) async {
    final all = await getAllTasks(userId);
    final idx = all.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final t = all[idx];
    final newStatus = t.status == TaskStatus.completed
        ? TaskStatus.todo
        : TaskStatus.completed;
    all[idx] = t.copyWith(status: newStatus);
    await _saveAllTasks(userId, all);
  }

  static Future<void> deleteTask(String userId, String taskId) async {
    final all = await getAllTasks(userId);
    all.removeWhere((t) => t.id == taskId);
    await _saveAllTasks(userId, all);
  }

  static Future<void> _deleteTasksByCourse(
      String userId, String courseId) async {
    final all = await getAllTasks(userId);
    final remaining = all.where((t) => t.courseId != courseId).toList();
    await _saveAllTasks(userId, remaining);
  }

  // ── EXAMS ────────────────────────────────────────────────────────────────

  static Future<List<Exam>> getAllExams(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key('exams', userId)) ?? [];
    return list.map(Exam.fromJson).toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  static Future<List<Exam>> getExamsForCourse(
      String userId, String courseId) async {
    final all = await getAllExams(userId);
    return all.where((e) => e.courseId == courseId).toList();
  }

  static Future<void> saveExam(String userId, Exam exam) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllExams(userId);
    all.removeWhere((e) => e.id == exam.id);
    all.add(exam.copyWith(userId: userId));
    await prefs.setStringList(
        _key('exams', userId), all.map((e) => e.toJson()).toList());
  }

  static Future<void> deleteExam(String userId, String examId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllExams(userId);
    all.removeWhere((e) => e.id == examId);
    await prefs.setStringList(
        _key('exams', userId), all.map((e) => e.toJson()).toList());
  }

  static Future<void> _deleteExamsByCourse(
      String userId, String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllExams(userId);
    final remaining = all.where((e) => e.courseId != courseId).toList();
    await prefs.setStringList(
        _key('exams', userId), remaining.map((e) => e.toJson()).toList());
  }

  // ── NOTES ─────────────────────────────────────────────────────────────────

  static Future<List<StudyNote>> getAllNotes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key('notes', userId)) ?? [];
    return list.map(StudyNote.fromJson).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Future<List<StudyNote>> getNotesForCourse(
      String userId, String courseId) async {
    final all = await getAllNotes(userId);
    return all.where((n) => n.courseId == courseId).toList();
  }

  static Future<void> saveNote(String userId, StudyNote note) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllNotes(userId);
    all.removeWhere((n) => n.id == note.id);
    all.add(note.copyWith(userId: userId));
    await prefs.setStringList(
        _key('notes', userId), all.map((n) => n.toJson()).toList());
  }

  static Future<void> deleteNote(String userId, String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllNotes(userId);
    all.removeWhere((n) => n.id == noteId);
    await prefs.setStringList(
        _key('notes', userId), all.map((n) => n.toJson()).toList());
  }

  static Future<void> _deleteNotesByCourse(
      String userId, String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllNotes(userId);
    final remaining = all.where((n) => n.courseId != courseId).toList();
    await prefs.setStringList(
        _key('notes', userId), remaining.map((n) => n.toJson()).toList());
  }

  // ── STUDY SESSIONS ────────────────────────────────────────────────────────

  static Future<List<StudySession>> getAllSessions(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key('sessions', userId)) ?? [];
    return list.map(StudySession.fromJson).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  static Future<void> saveSession(String userId, StudySession session) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllSessions(userId);
    all.removeWhere((s) => s.id == session.id);
    all.add(session.copyWith(userId: userId));
    await prefs.setStringList(
        _key('sessions', userId), all.map((s) => s.toJson()).toList());
  }

  static Future<void> deleteSession(String userId, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllSessions(userId);
    all.removeWhere((s) => s.id == sessionId);
    await prefs.setStringList(
        _key('sessions', userId), all.map((s) => s.toJson()).toList());
  }

  // ── SETTINGS ──────────────────────────────────────────────────────────────

  static Future<double> getDailyStudyHours(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('pref_daily_hours_$userId') ?? 3.0;
  }

  static Future<void> setDailyStudyHours(String userId, double hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pref_daily_hours_$userId', hours);
  }

  static Future<double> getWeeklyStudyHours(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('pref_weekly_hours_$userId') ?? 21.0;
  }

  static Future<void> setWeeklyStudyHours(String userId, double hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pref_weekly_hours_$userId', hours);
  }

  static Future<bool> getNotificationsEnabled(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pref_notif_$userId') ?? true;
  }

  static Future<void> setNotificationsEnabled(
      String userId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_notif_$userId', enabled);
  }

  static Future<bool> isDarkMode(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pref_dark_$userId') ?? true;
  }

  static Future<void> setDarkMode(String userId, bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_dark_$userId', dark);
  }

  static Future<int> getFocusDuration(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('pref_focus_min_$userId') ?? 25;
  }

  static Future<void> setFocusDuration(String userId, int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pref_focus_min_$userId', minutes);
  }

  static Future<int> getBreakDuration(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('pref_break_min_$userId') ?? 5;
  }

  static Future<void> setBreakDuration(String userId, int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pref_break_min_$userId', minutes);
  }

  static Future<String> getPreferredStudyStart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pref_study_start_$userId') ?? '09:00';
  }

  static Future<void> setPreferredStudyStart(
      String userId, String timeStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_study_start_$userId', timeStr);
  }

  // ── STREAK ────────────────────────────────────────────────────────────────

  static Future<int> getCurrentStreak(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('streak_current_$userId') ?? 0;
  }

  static Future<int> getLongestStreak(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('streak_longest_$userId') ?? 0;
  }

  static Future<String?> getLastStudyDate(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('streak_last_date_$userId');
  }

  /// Call this whenever a study session is completed to update streaks.
  static Future<void> recordStudyDay(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastDate = prefs.getString('streak_last_date_$userId');

    if (lastDate == today) return; // already recorded today

    int current = prefs.getInt('streak_current_$userId') ?? 0;
    int longest = prefs.getInt('streak_longest_$userId') ?? 0;

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    if (lastDate == yesterday) {
      current += 1;
    } else {
      current = 1; // streak broken
    }

    if (current > longest) longest = current;

    await prefs.setInt('streak_current_$userId', current);
    await prefs.setInt('streak_longest_$userId', longest);
    await prefs.setString('streak_last_date_$userId', today);
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── DATA MANAGEMENT ───────────────────────────────────────────────────────

  static Future<void> clearAllUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      _key('courses', userId),
      _key('topics', userId),
      _key('tasks', userId),
      _key('exams', userId),
      _key('notes', userId),
      _key('sessions', userId),
    ];
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

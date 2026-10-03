import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/course_model.dart';
import '../data/models/topic_model.dart';
import '../data/models/task_model.dart';
import '../data/models/exam_model.dart';
import '../data/models/note_model.dart';
import '../data/models/study_session_model.dart';
import '../data/services/storage_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/scheduler_service.dart';
import '../services/auth_service.dart';

/// Central application state provider.
/// Loaded once after login; all screens read from this provider.
class AppProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Course> _courses = [];
  List<Topic> _topics = [];
  List<StudyTask> _tasks = [];
  List<Exam> _exams = [];
  List<StudyNote> _notes = [];
  List<StudySession> _sessions = [];

  List<Course> get courses => _courses;
  List<Topic> get topics => _topics;
  List<StudyTask> get tasks => _tasks;
  List<Exam> get exams => _exams;
  List<StudyNote> get notes => _notes;
  List<StudySession> get sessions => _sessions;

  // Settings
  bool _isDarkMode = true;
  double _dailyHoursGoal = 3.0;
  double _weeklyHoursGoal = 21.0;
  bool _notificationsEnabled = true;
  int _focusDuration = 25;
  int _breakDuration = 5;
  String _preferredStudyStart = '09:00';

  bool get isDarkMode => _isDarkMode;
  double get dailyHoursGoal => _dailyHoursGoal;
  double get weeklyHoursGoal => _weeklyHoursGoal;
  bool get notificationsEnabled => _notificationsEnabled;
  int get focusDuration => _focusDuration;
  int get breakDuration => _breakDuration;
  String get preferredStudyStart => _preferredStudyStart;

  // Streak
  int _currentStreak = 0;
  int _longestStreak = 0;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  // ── User helpers ──────────────────────────────────────────────────────────
  String get _userId =>
      AuthService.currentUser?.id ?? 'local';

  // ── Load all data ─────────────────────────────────────────────────────────
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    final userId = _userId;

    // 1. Load from local storage immediately.
    final localResults = await Future.wait([
      StorageService.getCourses(userId),
      StorageService.getAllTopics(userId),
      StorageService.getAllTasks(userId),
      StorageService.getAllExams(userId),
      StorageService.getAllNotes(userId),
      StorageService.getAllSessions(userId),
      StorageService.isDarkMode(userId),
      StorageService.getDailyStudyHours(userId),
      StorageService.getWeeklyStudyHours(userId),
      StorageService.getNotificationsEnabled(userId),
      StorageService.getFocusDuration(userId),
      StorageService.getBreakDuration(userId),
      StorageService.getPreferredStudyStart(userId),
      StorageService.getCurrentStreak(userId),
      StorageService.getLongestStreak(userId),
    ]);

    _courses = localResults[0] as List<Course>;
    _topics = localResults[1] as List<Topic>;
    _tasks = localResults[2] as List<StudyTask>;
    _exams = localResults[3] as List<Exam>;
    _notes = localResults[4] as List<StudyNote>;
    _sessions = localResults[5] as List<StudySession>;
    _isDarkMode = localResults[6] as bool;
    _dailyHoursGoal = localResults[7] as double;
    _weeklyHoursGoal = localResults[8] as double;
    _notificationsEnabled = localResults[9] as bool;
    _focusDuration = localResults[10] as int;
    _breakDuration = localResults[11] as int;
    _preferredStudyStart = localResults[12] as String;
    _currentStreak = localResults[13] as int;
    _longestStreak = localResults[14] as int;

    _isLoading = false;
    notifyListeners();

    // 2. Sync from Firestore in the background and refresh if there is newer cloud data.
    _syncFromFirestore(userId);
  }

  Future<void> _syncFromFirestore(String userId) async {
    try {
      final cloud = await FirestoreService.fetchAll(userId);
      final courses = cloud['courses'] as List<Course>;
      final topics = cloud['topics'] as List<Topic>;
      final tasks = cloud['tasks'] as List<StudyTask>;
      final exams = cloud['exams'] as List<Exam>;
      final notes = cloud['notes'] as List<StudyNote>;
      final sessions = cloud['sessions'] as List<StudySession>;

      // Merge: cloud wins for any id that exists in both.
      _courses = _merge<Course>(_courses, courses, (x) => x.id);
      _topics = _merge<Topic>(_topics, topics, (x) => x.id);
      _tasks = _merge<StudyTask>(_tasks, tasks, (x) => x.id);
      _exams = _merge<Exam>(_exams, exams, (x) => x.id);
      _notes = _merge<StudyNote>(_notes, notes, (x) => x.id);
      _sessions = _merge<StudySession>(_sessions, sessions, (x) => x.id);

      // Persist merged data locally.
      await Future.wait([
        ...(_courses.map((c) => StorageService.saveCourse(userId, c))),
        ...(_topics.map((t) => StorageService.saveTopic(userId, t))),
        ...(_exams.map((e) => StorageService.saveExam(userId, e))),
        ...(_notes.map((n) => StorageService.saveNote(userId, n))),
        ...(_sessions.map((s) => StorageService.saveSession(userId, s))),
      ]);
      await StorageService.saveAllTasks(userId, _tasks);

      notifyListeners();
    } catch (_) {
      // Firestore unavailable (offline) — local data already shown.
    }
  }

  /// Merge [local] and [remote] lists; remote items overwrite local ones.
  List<T> _merge<T>(List<T> local, List<T> remote, String Function(T) getId) {
    final map = <String, T>{};
    for (final item in local) {
      map[getId(item)] = item;
    }
    for (final item in remote) {
      map[getId(item)] = item;
    }
    return map.values.toList();
  }

  // ── COURSES ───────────────────────────────────────────────────────────────

  Future<void> addCourse(Course course) async {
    await StorageService.saveCourse(_userId, course);
    _courses = await StorageService.getCourses(_userId);
    FirestoreService.saveCourse(_userId, course);
    notifyListeners();
  }

  Future<void> updateCourse(Course course) async {
    await StorageService.saveCourse(_userId, course);
    _courses = await StorageService.getCourses(_userId);
    FirestoreService.saveCourse(_userId, course);
    notifyListeners();
  }

  Future<void> deleteCourse(String courseId) async {
    await StorageService.deleteCourse(_userId, courseId);
    _courses = await StorageService.getCourses(_userId);
    _topics = await StorageService.getAllTopics(_userId);
    _tasks = await StorageService.getAllTasks(_userId);
    _exams = await StorageService.getAllExams(_userId);
    _notes = await StorageService.getAllNotes(_userId);
    FirestoreService.deleteCourse(_userId, courseId);
    FirestoreService.deleteByCourse(_userId, courseId);
    notifyListeners();
  }

  Future<void> archiveCourse(String courseId) async {
    final course = _courses.firstWhere((c) => c.id == courseId);
    await updateCourse(course.copyWith(status: CourseStatus.archived));
  }

  Future<void> unarchiveCourse(String courseId) async {
    final course = _courses.firstWhere((c) => c.id == courseId);
    await updateCourse(course.copyWith(status: CourseStatus.active));
  }

  List<Course> get activeCourses =>
      _courses.where((c) => c.isActive).toList();
  List<Course> get archivedCourses =>
      _courses.where((c) => c.isArchived).toList();

  // ── TOPICS ────────────────────────────────────────────────────────────────

  List<Topic> topicsForCourse(String courseId) =>
      _topics.where((t) => t.courseId == courseId).toList();

  Future<void> addTopic(Topic topic) async {
    await StorageService.saveTopic(_userId, topic);
    _topics = await StorageService.getAllTopics(_userId);
    FirestoreService.saveTopic(_userId, topic);
    notifyListeners();
  }

  Future<void> updateTopic(Topic topic) async {
    await StorageService.saveTopic(_userId, topic);
    _topics = await StorageService.getAllTopics(_userId);
    FirestoreService.saveTopic(_userId, topic);
    // Recalculate course completed hours
    await _updateCourseProgress(topic.courseId);
    notifyListeners();
  }

  Future<void> deleteTopic(String topicId) async {
    final topic = _topics.firstWhere((t) => t.id == topicId);
    await StorageService.deleteTopic(_userId, topicId);
    _topics = await StorageService.getAllTopics(_userId);
    _tasks = await StorageService.getAllTasks(_userId);
    FirestoreService.deleteTopic(_userId, topicId);
    await _updateCourseProgress(topic.courseId);
    notifyListeners();
  }

  Future<void> markTopicCompleted(String topicId) async {
    final idx = _topics.indexWhere((t) => t.id == topicId);
    if (idx == -1) return;
    final updated = _topics[idx].copyWith(status: TopicStatus.completed);
    await updateTopic(updated);
  }

  Future<void> _updateCourseProgress(String courseId) async {
    final courseTopics = _topics.where((t) => t.courseId == courseId);
    final completedHours = courseTopics
        .where((t) => t.isCompleted)
        .fold<double>(0, (sum, t) => sum + t.estimatedHours);
    final courseIdx = _courses.indexWhere((c) => c.id == courseId);
    if (courseIdx == -1) return;
    final updated = _courses[courseIdx].copyWith(completedHours: completedHours);
    await StorageService.saveCourse(_userId, updated);
    _courses = await StorageService.getCourses(_userId);
  }

  // ── TASKS ─────────────────────────────────────────────────────────────────

  List<StudyTask> tasksForDate(DateTime date) => _tasks.where((t) =>
      t.scheduledDate.year == date.year &&
      t.scheduledDate.month == date.month &&
      t.scheduledDate.day == date.day).toList();

  List<StudyTask> tasksForCourse(String courseId) =>
      _tasks.where((t) => t.courseId == courseId).toList();

  List<StudyTask> get pendingTasks =>
      _tasks.where((t) => !t.completed).toList();

  List<StudyTask> get overdueTasks => _tasks.where((t) => t.isOverdue).toList();

  Future<void> addTask(StudyTask task) async {
    await StorageService.saveTask(_userId, task);
    _tasks = await StorageService.getAllTasks(_userId);
    FirestoreService.saveTask(_userId, task);
    notifyListeners();
  }

  Future<void> updateTask(StudyTask task) async {
    await StorageService.saveTask(_userId, task);
    _tasks = await StorageService.getAllTasks(_userId);
    FirestoreService.saveTask(_userId, task);
    notifyListeners();
  }

  Future<void> toggleTask(String taskId) async {
    await StorageService.toggleTaskCompleted(_userId, taskId);
    _tasks = await StorageService.getAllTasks(_userId);
    FirestoreService.toggleTaskCompleted(_userId, taskId);
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await StorageService.deleteTask(_userId, taskId);
    _tasks = await StorageService.getAllTasks(_userId);
    FirestoreService.deleteTask(_userId, taskId);
    notifyListeners();
  }

  // ── SMART SCHEDULE GENERATION ─────────────────────────────────────────────

  Future<int> generateSchedule() async {
    // Remove old auto-generated non-completed tasks
    final kept =
        _tasks.where((t) => !t.isAutoGenerated || t.completed).toList();

    final scheduler = SmartScheduler(
      courses: activeCourses,
      topics: _topics,
      exams: _exams,
      existingTasks: kept,
      dailyHoursLimit: _dailyHoursGoal,
      preferredStartHour: _parseStartHour(_preferredStudyStart),
    );

    final generated = scheduler.generate();
    final combined = [...kept, ...generated];
    await StorageService.saveAllTasks(_userId, combined);
    _tasks = await StorageService.getAllTasks(_userId);
    FirestoreService.saveAllTasks(_userId, combined);
    notifyListeners();
    return generated.length;
  }

  int _parseStartHour(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.isEmpty) return 9;
    return int.tryParse(parts[0]) ?? 9;
  }

  // ── EXAMS ─────────────────────────────────────────────────────────────────

  List<Exam> examsForCourse(String courseId) =>
      _exams.where((e) => e.courseId == courseId).toList();

  List<Exam> get upcomingExams =>
      _exams.where((e) => !e.isPast).toList();

  Future<void> addExam(Exam exam) async {
    await StorageService.saveExam(_userId, exam);
    _exams = await StorageService.getAllExams(_userId);
    FirestoreService.saveExam(_userId, exam);
    notifyListeners();
  }

  Future<void> updateExam(Exam exam) async {
    await StorageService.saveExam(_userId, exam);
    _exams = await StorageService.getAllExams(_userId);
    FirestoreService.saveExam(_userId, exam);
    notifyListeners();
  }

  Future<void> deleteExam(String examId) async {
    await StorageService.deleteExam(_userId, examId);
    _exams = await StorageService.getAllExams(_userId);
    FirestoreService.deleteExam(_userId, examId);
    notifyListeners();
  }

  // ── NOTES ─────────────────────────────────────────────────────────────────

  List<StudyNote> notesForCourse(String courseId) =>
      _notes.where((n) => n.courseId == courseId).toList();

  Future<void> addNote(StudyNote note) async {
    await StorageService.saveNote(_userId, note);
    _notes = await StorageService.getAllNotes(_userId);
    FirestoreService.saveNote(_userId, note);
    notifyListeners();
  }

  Future<void> updateNote(StudyNote note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await StorageService.saveNote(_userId, updated);
    _notes = await StorageService.getAllNotes(_userId);
    FirestoreService.saveNote(_userId, updated);
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await StorageService.deleteNote(_userId, noteId);
    _notes = await StorageService.getAllNotes(_userId);
    FirestoreService.deleteNote(_userId, noteId);
    notifyListeners();
  }

  // ── STUDY SESSIONS ────────────────────────────────────────────────────────

  Future<void> addSession(StudySession session) async {
    await StorageService.saveSession(_userId, session);
    await StorageService.recordStudyDay(_userId);
    _sessions = await StorageService.getAllSessions(_userId);
    _currentStreak = await StorageService.getCurrentStreak(_userId);
    _longestStreak = await StorageService.getLongestStreak(_userId);
    FirestoreService.saveSession(_userId, session);
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    await StorageService.deleteSession(_userId, sessionId);
    _sessions = await StorageService.getAllSessions(_userId);
    FirestoreService.deleteSession(_userId, sessionId);
    notifyListeners();
  }

  // ── SETTINGS ──────────────────────────────────────────────────────────────

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.setDarkMode(_userId, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDailyHoursGoal(double hours) async {
    _dailyHoursGoal = hours;
    await StorageService.setDailyStudyHours(_userId, hours);
    notifyListeners();
  }

  Future<void> setWeeklyHoursGoal(double hours) async {
    _weeklyHoursGoal = hours;
    await StorageService.setWeeklyStudyHours(_userId, hours);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await StorageService.setNotificationsEnabled(_userId, enabled);
    notifyListeners();
  }

  Future<void> setFocusDuration(int minutes) async {
    _focusDuration = minutes;
    await StorageService.setFocusDuration(_userId, minutes);
    notifyListeners();
  }

  Future<void> setBreakDuration(int minutes) async {
    _breakDuration = minutes;
    await StorageService.setBreakDuration(_userId, minutes);
    notifyListeners();
  }

  Future<void> setPreferredStudyStart(String timeStr) async {
    _preferredStudyStart = timeStr;
    await StorageService.setPreferredStudyStart(_userId, timeStr);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await StorageService.clearAllUserData(_userId);
    _courses = [];
    _topics = [];
    _tasks = [];
    _exams = [];
    _notes = [];
    _sessions = [];
    notifyListeners();
  }

  // ── ANALYTICS ─────────────────────────────────────────────────────────────

  /// Total study hours this week (from sessions).
  double get weeklyStudyHours {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _sessions
        .where((s) => s.startTime.isAfter(
            DateTime(weekStart.year, weekStart.month, weekStart.day)))
        .fold(0.0, (sum, s) => sum + s.durationHours);
  }

  /// Total study hours today (from sessions).
  double get todayStudyHours {
    final now = DateTime.now();
    return _sessions
        .where((s) =>
            s.startTime.year == now.year &&
            s.startTime.month == now.month &&
            s.startTime.day == now.day)
        .fold(0.0, (sum, s) => sum + s.durationHours);
  }

  /// Study hours per day for the last 7 days (index 0 = oldest).
  List<double> get last7DaysHours {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _sessions
          .where((s) =>
              s.startTime.year == day.year &&
              s.startTime.month == day.month &&
              s.startTime.day == day.day)
          .fold(0.0, (sum, s) => sum + s.durationHours);
    });
  }

  /// Hours per course from sessions.
  Map<String, double> get hoursByCourse {
    final map = <String, double>{};
    for (final s in _sessions) {
      map[s.courseId] = (map[s.courseId] ?? 0) + s.durationHours;
    }
    return map;
  }

  double get totalStudyHours =>
      _sessions.fold(0.0, (sum, s) => sum + s.durationHours);

  double get averageSessionMinutes {
    if (_sessions.isEmpty) return 0;
    final totalMin =
        _sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    return totalMin / _sessions.length;
  }

  /// Overall task completion rate (0.0 – 1.0).
  double get completionRate {
    if (_tasks.isEmpty) return 0;
    final done = _tasks.where((t) => t.completed).length;
    return done / _tasks.length;
  }

  // ── ID GENERATION ─────────────────────────────────────────────────────────
  String newId() => _uuid.v4();
}

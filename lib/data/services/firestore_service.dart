import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/task_model.dart';
import '../models/exam_model.dart';
import '../models/note_model.dart';
import '../models/study_session_model.dart';
import '../models/user_model.dart';

/// Cloud Firestore sync service.
///
/// Data layout:
///   users/{uid}/courses/{courseId}
///   users/{uid}/topics/{topicId}
///   users/{uid}/tasks/{taskId}
///   users/{uid}/exams/{examId}
///   users/{uid}/notes/{noteId}
///   users/{uid}/sessions/{sessionId}
///
/// Each write is fire-and-forget (unawaited from the provider) so it never
/// blocks the UI. Reads are only used at login time for the initial sync.
class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Collection refs ────────────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> _col(
          String uid, String col) =>
      _db.collection('users').doc(uid).collection(col);

  // ── Firestore map helpers ──────────────────────────────────────────────────

  /// Convert a millisecond epoch integer to a Firestore Timestamp.
  static Timestamp _ts(int ms) =>
      Timestamp.fromMillisecondsSinceEpoch(ms);

  /// Convert our model's toMap() output to a Firestore-friendly map,
  /// replacing epoch-int timestamps with Firestore Timestamps.
  static Map<String, dynamic> _toFirestore(
      Map<String, dynamic> raw, List<String> tsFields) {
    final map = Map<String, dynamic>.from(raw);
    for (final field in tsFields) {
      if (map[field] is int) {
        map[field] = _ts(map[field] as int);
      }
    }
    return map;
  }

  /// Convert a Firestore map back to our model-compatible raw map,
  /// replacing Timestamp values back to millisecondsSinceEpoch ints.
  static Map<String, dynamic> _fromFirestore(Map<String, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    for (final entry in map.entries.toList()) {
      if (entry.value is Timestamp) {
        map[entry.key] = (entry.value as Timestamp).millisecondsSinceEpoch;
      }
    }
    return map;
  }

  // ── USER PROFILE ───────────────────────────────────────────────────────────

  static Future<void> saveUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.id).set({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'created_at': _ts(user.createdAt.millisecondsSinceEpoch),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(_fromFirestore(doc.data()!));
  }

  // ── COURSES ────────────────────────────────────────────────────────────────

  static Future<void> saveCourse(String uid, Course course) async {
    final map = _toFirestore(course.toMap(), ['deadline', 'created_at']);
    await _col(uid, 'courses').doc(course.id).set(map);
  }

  static Future<void> deleteCourse(String uid, String courseId) async {
    await _col(uid, 'courses').doc(courseId).delete();
  }

  static Future<List<Course>> getCourses(String uid) async {
    final snap = await _col(uid, 'courses').get();
    return snap.docs
        .map((d) => Course.fromMap(_fromFirestore(d.data())))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // ── TOPICS ─────────────────────────────────────────────────────────────────

  static Future<void> saveTopic(String uid, Topic topic) async {
    final map = _toFirestore(topic.toMap(), ['deadline', 'created_at']);
    await _col(uid, 'topics').doc(topic.id).set(map);
  }

  static Future<void> deleteTopic(String uid, String topicId) async {
    await _col(uid, 'topics').doc(topicId).delete();
  }

  static Future<List<Topic>> getTopics(String uid) async {
    final snap = await _col(uid, 'topics').get();
    return snap.docs
        .map((d) => Topic.fromMap(_fromFirestore(d.data())))
        .toList();
  }

  // ── TASKS ──────────────────────────────────────────────────────────────────

  static Future<void> saveTask(String uid, StudyTask task) async {
    final map = _toFirestore(
        task.toMap(), ['scheduled_date', 'deadline', 'created_at']);
    await _col(uid, 'tasks').doc(task.id).set(map);
  }

  static Future<void> deleteTask(String uid, String taskId) async {
    await _col(uid, 'tasks').doc(taskId).delete();
  }

  static Future<List<StudyTask>> getTasks(String uid) async {
    final snap = await _col(uid, 'tasks').get();
    return snap.docs
        .map((d) => StudyTask.fromMap(_fromFirestore(d.data())))
        .toList();
  }

  static Future<void> saveAllTasks(String uid, List<StudyTask> tasks) async {
    final batch = _db.batch();
    final ref = _col(uid, 'tasks');
    for (final t in tasks) {
      final map = _toFirestore(
          t.toMap(), ['scheduled_date', 'deadline', 'created_at']);
      batch.set(ref.doc(t.id), map);
    }
    await batch.commit();
  }

  static Future<void> toggleTaskCompleted(String uid, String taskId) async {
    final doc = await _col(uid, 'tasks').doc(taskId).get();
    if (!doc.exists) return;
    final data = _fromFirestore(doc.data()!);
    final currentStatus = data['status'] as int? ?? 0;
    final newStatus = currentStatus == TaskStatus.completed.index
        ? TaskStatus.todo.index
        : TaskStatus.completed.index;
    await _col(uid, 'tasks').doc(taskId).update({'status': newStatus});
  }

  // ── EXAMS ──────────────────────────────────────────────────────────────────

  static Future<void> saveExam(String uid, Exam exam) async {
    final map = _toFirestore(exam.toMap(), ['exam_date', 'created_at']);
    await _col(uid, 'exams').doc(exam.id).set(map);
  }

  static Future<void> deleteExam(String uid, String examId) async {
    await _col(uid, 'exams').doc(examId).delete();
  }

  static Future<List<Exam>> getExams(String uid) async {
    final snap = await _col(uid, 'exams').get();
    return snap.docs
        .map((d) => Exam.fromMap(_fromFirestore(d.data())))
        .toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  // ── NOTES ──────────────────────────────────────────────────────────────────

  static Future<void> saveNote(String uid, StudyNote note) async {
    final map = _toFirestore(note.toMap(), ['created_at', 'updated_at']);
    await _col(uid, 'notes').doc(note.id).set(map);
  }

  static Future<void> deleteNote(String uid, String noteId) async {
    await _col(uid, 'notes').doc(noteId).delete();
  }

  static Future<List<StudyNote>> getNotes(String uid) async {
    final snap = await _col(uid, 'notes').get();
    return snap.docs
        .map((d) => StudyNote.fromMap(_fromFirestore(d.data())))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // ── STUDY SESSIONS ─────────────────────────────────────────────────────────

  static Future<void> saveSession(String uid, StudySession session) async {
    final map =
        _toFirestore(session.toMap(), ['start_time', 'end_time']);
    await _col(uid, 'sessions').doc(session.id).set(map);
  }

  static Future<void> deleteSession(String uid, String sessionId) async {
    await _col(uid, 'sessions').doc(sessionId).delete();
  }

  static Future<List<StudySession>> getSessions(String uid) async {
    final snap = await _col(uid, 'sessions').get();
    return snap.docs
        .map((d) => StudySession.fromMap(_fromFirestore(d.data())))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // ── CASCADE DELETE (when a course is deleted) ──────────────────────────────

  /// Deletes all Firestore docs whose `course_id` field equals [courseId].
  static Future<void> deleteByCourse(String uid, String courseId) async {
    final collections = ['topics', 'tasks', 'exams', 'notes'];
    for (final colName in collections) {
      final snap = await _col(uid, colName)
          .where('course_id', isEqualTo: courseId)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      if (snap.docs.isNotEmpty) await batch.commit();
    }
  }

  /// Full sync: fetches ALL user data from Firestore.
  /// Called once after login to merge cloud data into local storage.
  static Future<Map<String, List<dynamic>>> fetchAll(String uid) async {
    final results = await Future.wait([
      getCourses(uid),
      getTopics(uid),
      getTasks(uid),
      getExams(uid),
      getNotes(uid),
      getSessions(uid),
    ]);
    return {
      'courses': results[0],
      'topics': results[1],
      'tasks': results[2],
      'exams': results[3],
      'notes': results[4],
      'sessions': results[5],
    };
  }
}

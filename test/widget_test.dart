import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_planner/models/course_model.dart';
import 'package:study_planner/models/topic_model.dart';
import 'package:study_planner/models/task_model.dart';
import 'package:study_planner/models/user_model.dart';
import 'package:study_planner/services/local_storage_service.dart';
import 'package:study_planner/services/scheduler_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Data Model Tests', () {
    test('UserModel serialization and deserialization', () {
      final user = UserModel(
        id: 'user_123',
        name: 'Ronit Vyas',
        email: 'ronit@example.com',
      );

      final json = user.toJson();
      final parsed = UserModel.fromJson(json);

      expect(parsed.id, equals('user_123'));
      expect(parsed.name, equals('Ronit Vyas'));
      expect(parsed.email, equals('ronit@example.com'));
    });

    test('Course serialization and deserialization', () {
      final course = Course(
        id: 'course_1',
        userId: 'user_123',
        name: 'Data Structures',
        description: 'Trees and Graphs',
        deadline: DateTime(2026, 10, 15),
        priority: 'High',
        estimatedHours: 20.0,
      );

      final json = course.toJson();
      final parsed = Course.fromJson(json);

      expect(parsed.id, equals('course_1'));
      expect(parsed.userId, equals('user_123'));
      expect(parsed.name, equals('Data Structures'));
      expect(parsed.priority, equals('High'));
      expect(parsed.estimatedHours, equals(20.0));
    });

    test('Topic serialization and deserialization', () {
      final topic = Topic(
        id: 'topic_1',
        courseId: 'course_1',
        name: 'Binary Trees',
        estimatedHours: 4.5,
      );

      final json = topic.toJson();
      final parsed = Topic.fromJson(json);

      expect(parsed.id, equals('topic_1'));
      expect(parsed.courseId, equals('course_1'));
      expect(parsed.name, equals('Binary Trees'));
      expect(parsed.estimatedHours, equals(4.5));
    });

    test('StudyTask serialization and deserialization', () {
      final task = StudyTask(
        id: 'task_1',
        userId: 'user_123',
        courseId: 'course_1',
        topicId: 'topic_1',
        date: DateTime(2026, 10, 1),
        duration: 2.0,
        completed: true,
      );

      final json = task.toJson();
      final parsed = StudyTask.fromJson(json);

      expect(parsed.id, equals('task_1'));
      expect(parsed.userId, equals('user_123'));
      expect(parsed.courseId, equals('course_1'));
      expect(parsed.duration, equals(2.0));
      expect(parsed.completed, isTrue);
    });
  });

  group('Local Device Storage Service Tests', () {
    test('Courses are stored and retrieved locally on device', () async {
      final course = Course(
        id: 'local_c1',
        name: 'Algorithms',
        description: 'Sorting and Searching',
        deadline: DateTime.now().add(const Duration(days: 10)),
        priority: 'High',
        estimatedHours: 15.0,
      );

      await LocalStorageService.addCourse(course, userId: 'test_user');
      final loaded = await LocalStorageService.getCourses(userId: 'test_user');

      expect(loaded.length, equals(1));
      expect(loaded.first.id, equals('local_c1'));
      expect(loaded.first.name, equals('Algorithms'));

      await LocalStorageService.deleteCourse('local_c1', userId: 'test_user');
      final afterDelete =
          await LocalStorageService.getCourses(userId: 'test_user');
      expect(afterDelete, isEmpty);
    });

    test('Tasks are stored, retrieved, and toggled locally on device', () async {
      final task = StudyTask(
        id: 'local_t1',
        courseId: 'local_c1',
        topicId: 'local_top1',
        date: DateTime.now(),
        duration: 2.5,
        completed: false,
      );

      await LocalStorageService.addTask(task, userId: 'test_user');
      var allTasks = await LocalStorageService.getAllTasks(userId: 'test_user');
      expect(allTasks.length, equals(1));
      expect(allTasks.first.completed, isFalse);

      await LocalStorageService.toggleTaskCompleted('local_t1', userId: 'test_user');
      allTasks = await LocalStorageService.getAllTasks(userId: 'test_user');
      expect(allTasks.first.completed, isTrue);
    });

    test('Notification and daily hours preferences are stored locally', () async {
      await LocalStorageService.setDailyStudyHours(4.5, userId: 'test_user');
      final hours = await LocalStorageService.getDailyStudyHours(userId: 'test_user');
      expect(hours, equals(4.5));

      await LocalStorageService.setNotificationsEnabled(false, userId: 'test_user');
      final notifs = await LocalStorageService.getNotificationsEnabled(userId: 'test_user');
      expect(notifs, isFalse);
    });
  });

  group('Scheduler Service Tests', () {
    test('Scheduler distributes topics into tasks respecting daily limit', () {
      final course = Course(
        id: 'c1',
        name: 'OS',
        description: 'Processes',
        deadline: DateTime.now().add(const Duration(days: 5)),
        priority: 'High',
        estimatedHours: 6.0,
      );

      final topic = Topic(
        id: 'top1',
        courseId: 'c1',
        name: 'Scheduling',
        estimatedHours: 6.0,
      );

      final tasks = SchedulerService.generateSchedule(
        courses: [course],
        topics: [topic],
        hoursPerDay: 3.0,
      );

      expect(tasks.length, equals(2));
      expect(tasks[0].duration, equals(3.0));
      expect(tasks[1].duration, equals(3.0));
    });
  });
}

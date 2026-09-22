import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'local_storage_service.dart';
import '../models/course_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize local notification channels and settings.
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const LinuxInitializationSettings linuxSettings =
          LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: linuxSettings,
      );

      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      _isInitialized = true;
      debugPrint('NotificationService successfully initialized.');
    } catch (e) {
      debugPrint('Notification initialization skipped or unsupported: $e');
    }
  }

  /// Request permissions on Android 13+ (API 33+)
  static Future<bool> requestPermissions() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        final granted =
            await androidPlatform.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return true;
  }

  /// Show an instant study or deadline notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      debugPrint('Web notification: [$title] $body');
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'study_planner_reminders',
        'Study Reminders',
        channelDescription: 'Notifications for daily study tasks and upcoming deadlines',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show local notification: $e');
    }
  }

  /// Checks today's tasks and alerts the user if there are pending study tasks
  static Future<void> checkAndNotifyPendingTasks() async {
    final enabled = await LocalStorageService.getNotificationsEnabled();
    if (!enabled) return;

    final now = DateTime.now();
    final todayTasks = await LocalStorageService.getTasksForDate(now);
    final pendingTasks = todayTasks.where((t) => !t.completed).toList();

    if (pendingTasks.isNotEmpty) {
      final taskWord = pendingTasks.length == 1 ? 'task' : 'tasks';
      await showNotification(
        id: 101,
        title: '🔔 Daily Study Reminder',
        body: 'You have ${pendingTasks.length} pending $taskWord for today. Keep up the momentum!',
      );
    }
  }

  /// Checks if any course deadlines are within the next 48 hours
  static Future<void> checkAndNotifyUpcomingDeadlines(List<Course> courses) async {
    final enabled = await LocalStorageService.getNotificationsEnabled();
    if (!enabled) return;

    final now = DateTime.now();
    for (int i = 0; i < courses.length; i++) {
      final course = courses[i];
      final difference = course.deadline.difference(now);

      // Notify if deadline is between 0 and 48 hours away
      if (!difference.isNegative && difference.inHours <= 48) {
        final hoursLeft = difference.inHours;
        final timeText = hoursLeft < 24
            ? '$hoursLeft hours'
            : '${(hoursLeft / 24).ceil()} day(s)';

        await showNotification(
          id: 200 + i,
          title: '⚠️ Approaching Course Deadline',
          body: '${course.name} is due in $timeText! Make sure your topics are completed.',
        );
      }
    }
  }
}

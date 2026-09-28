import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int totalCourses = 0;
  int totalTasks = 0;
  int completedTasks = 0;
  bool notificationsEnabled = true;
  double dailyStudyHours = 3;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final results = await Future.wait([
      LocalStorageService.getCourses(),
      LocalStorageService.getAllTasks(),
      LocalStorageService.getNotificationsEnabled(),
      LocalStorageService.getDailyStudyHours(),
    ]);

    if (!mounted) return;

    final tasks = results[1] as List;
    setState(() {
      totalCourses = (results[0] as List).length;
      totalTasks = tasks.length;
      completedTasks = tasks.where((t) => t.completed).length;
      notificationsEnabled = results[2] as bool;
      dailyStudyHours = results[3] as double;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Your locally stored study data will remain on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    }
  }

  Future<void> _studyPreferences() async {
    double value = dailyStudyHours;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Study preferences', style: AppTextStyles.title),
                const SizedBox(height: 6),
                const Text(
                  'This is used when generating your study schedule.',
                  style: AppTextStyles.muted,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5, left: 5),
                      child: Text('hours / day', style: AppTextStyles.muted),
                    ),
                  ],
                ),
                Slider(
                  value: value,
                  min: 0.5,
                  max: 12,
                  divisions: 23,
                  label: '${value.toStringAsFixed(1)}h',
                  onChanged: (next) => setSheetState(() => value = next),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await LocalStorageService.setDailyStudyHours(value);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (mounted) setState(() => dailyStudyHours = value);
                    },
                    child: const Text('Save preference'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _notificationSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications', style: AppTextStyles.title),
              const SizedBox(height: 6),
              const Text(
                'Study reminders and approaching deadlines.',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Study reminders'),
                value: notificationsEnabled,
                onChanged: (value) async {
                  await LocalStorageService.setNotificationsEnabled(value);
                  setSheetState(() => notificationsEnabled = value);
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService.showNotification(
                    id: 999,
                    title: 'Study Planner',
                    body: 'Notifications are working.',
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification sent.')),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Send test notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _storageInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Local storage'),
        content: const Text(
          'Your courses, topics, tasks, completion status, and planner preferences are stored locally on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final name = user?.name ?? 'Student';
    final email = user?.email ?? 'student@example.com';
    final maxWidth = MediaQuery.sizeOf(context).width > 900 ? 760.0 : double.infinity;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              22,
              AppSpacing.page,
              36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: AppTextStyles.display),
                const SizedBox(height: AppSpacing.section),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(name, style: AppTextStyles.title),
                      const SizedBox(height: 3),
                      Text(email, style: AppTextStyles.muted),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                _section(
                  'Study Summary',
                  Row(
                    children: [
                      _stat('Courses', '$totalCourses'),
                      _stat('Tasks', '$totalTasks'),
                      _stat('Completed', '$completedTasks'),
                    ],
                  ),
                ),
                _section(
                  'Settings',
                  Column(
                    children: [
                      _settingRow(
                        Icons.tune_rounded,
                        'Study preferences',
                        '${dailyStudyHours.toStringAsFixed(dailyStudyHours % 1 == 0 ? 0 : 1)}h available per day',
                        _studyPreferences,
                      ),
                      const Divider(),
                      _settingRow(
                        Icons.notifications_none_rounded,
                        'Notifications',
                        notificationsEnabled ? 'Enabled' : 'Disabled',
                        _notificationSettings,
                      ),
                      const Divider(),
                      _settingRow(
                        Icons.storage_outlined,
                        'Storage',
                        'Study data is stored on this device',
                        _storageInfo,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text(
                      'Log out',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.display.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.muted),
        ],
      ),
    );
  }

  Widget _settingRow(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 40,
      horizontalTitleGap: 10,
      leading: Icon(icon, color: AppColors.mutedText),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.muted),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
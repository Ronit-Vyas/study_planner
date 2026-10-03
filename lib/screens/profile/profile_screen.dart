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
        content: const Text('Your locally saved study plan and topics remain safe on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: AppColors.error)),
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
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Study Quota', style: AppTextStyles.title),
                const SizedBox(height: 6),
                const Text(
                  'The scheduler will limit daily scheduled tasks to this amount of hours.',
                  style: AppTextStyles.muted,
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                      style: AppTextStyles.hero.copyWith(color: AppColors.primary, fontSize: 36),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, left: 6),
                      child: Text('hours / day', style: AppTextStyles.bodyBold),
                    ),
                  ],
                ),
                Slider(
                  value: value,
                  min: 0.5,
                  max: 12,
                  divisions: 23,
                  activeColor: AppColors.primary,
                  label: '${value.toStringAsFixed(1)}h',
                  onChanged: (next) => setSheetState(() => value = next),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      await LocalStorageService.setDailyStudyHours(value);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (mounted) setState(() => dailyStudyHours = value);
                    },
                    child: const Text('Save Preference'),
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications', style: AppTextStyles.title),
              const SizedBox(height: 6),
              const Text(
                'Receive daily morning reminders and approaching deadline alerts.',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile.adaptive(
                  activeTrackColor: AppColors.primary,
                  title: const Text('Study Reminders', style: AppTextStyles.bodyBold),
                  subtitle: const Text('Remind me about tasks for today', style: AppTextStyles.muted),
                  value: notificationsEnabled,
                  onChanged: (value) async {
                    await LocalStorageService.setNotificationsEnabled(value);
                    setSheetState(() => notificationsEnabled = value);
                    if (mounted) setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await NotificationService.showNotification(
                      id: 999,
                      title: 'Study Planner Test',
                      body: 'Study reminders are active and working smoothly!',
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Test notification sent successfully.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Send Test Notification'),
                ),
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
        title: const Text('Local & Secure Storage'),
        content: const Text(
          'Your courses, topics, study tasks, and daily preferences are stored safely on this device. No external servers have access to your personal study records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final name = user?.name ?? 'Ronit Vyas';
    final email = user?.email ?? 'ronit@example.com';
    final maxWidth = MediaQuery.sizeOf(context).width > 900 ? 760.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 20, AppSpacing.page, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile & Settings', style: AppTextStyles.hero),
                  const SizedBox(height: 20),

                  // User Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'S',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.title),
                              const SizedBox(height: 2),
                              Text(email, style: AppTextStyles.muted),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Student Member',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Study Summary Card
                  Text('STUDY PERFORMANCE', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        _statCard('Courses', '$totalCourses', Icons.menu_book),
                        Container(width: 1, height: 40, color: AppColors.cardBorder),
                        _statCard('Total Tasks', '$totalTasks', Icons.assignment_outlined),
                        Container(width: 1, height: 40, color: AppColors.cardBorder),
                        _statCard('Completed', '$completedTasks', Icons.check_circle_outline),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Settings Section
                  Text('PREFERENCES', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _settingTile(
                          icon: Icons.tune_rounded,
                          title: 'Study Preferences',
                          subtitle: '${dailyStudyHours.toStringAsFixed(dailyStudyHours % 1 == 0 ? 0 : 1)}h max study time per day',
                          onTap: _studyPreferences,
                        ),
                        const Divider(height: 1),
                        _settingTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications & Reminders',
                          subtitle: notificationsEnabled ? 'Active morning alerts' : 'Disabled',
                          onTap: _notificationSettings,
                        ),
                        const Divider(height: 1),
                        _settingTile(
                          icon: Icons.storage_outlined,
                          title: 'Storage & Privacy',
                          subtitle: 'Encrypted local device storage',
                          onTap: _storageInfo,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
                      label: const Text('Log out of Account', style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.errorLight, width: 1.5),
                        backgroundColor: AppColors.errorLight.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.title.copyWith(fontSize: 22)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.muted.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.bodyBold),
      subtitle: Text(subtitle, style: AppTextStyles.muted.copyWith(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.mutedText),
      onTap: onTap,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final user = AuthService.currentUser;

    final userName = user?.name.isNotEmpty == true ? user!.name : 'Student';
    final userEmail = user?.email ?? 'student@example.com';
    final initials = userName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            // ── User Profile Header ──────────────────────────────────────────
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials.isNotEmpty ? initials : 'S',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                        Text(userName, style: AppTextStyles.title),
                        const SizedBox(height: 2),
                        Text(userEmail, style: AppTextStyles.caption),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentAmber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department_rounded,
                                      size: 14, color: AppColors.accentAmber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${provider.currentStreak} Day Streak',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentAmber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Study Goals Section ──────────────────────────────────────────
            AppSection(
              title: 'Study Goals & Targets',
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.today_rounded, color: AppColors.primary),
                      title: const Text('Daily Study Goal'),
                      subtitle: Text('${provider.dailyHoursGoal.toStringAsFixed(1)} hours / day'),
                      trailing: DropdownButton<double>(
                        value: provider.dailyHoursGoal,
                        underline: const SizedBox(),
                        items: [1.0, 2.0, 2.5, 3.0, 4.0, 5.0, 6.0, 8.0]
                            .map((h) => DropdownMenuItem(value: h, child: Text('${h.toStringAsFixed(1)}h')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) provider.setDailyHoursGoal(val);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.date_range_rounded, color: AppColors.accent),
                      title: const Text('Weekly Study Goal'),
                      subtitle: Text('${provider.weeklyHoursGoal.toInt()} hours / week'),
                      trailing: DropdownButton<double>(
                        value: provider.weeklyHoursGoal,
                        underline: const SizedBox(),
                        items: [10.0, 15.0, 20.0, 21.0, 25.0, 30.0, 40.0]
                            .map((h) => DropdownMenuItem(value: h, child: Text('${h.toInt()}h')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) provider.setWeeklyHoursGoal(val);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.timer_outlined, color: AppColors.accentRose),
                      title: const Text('Focus Timer Duration'),
                      subtitle: Text('${provider.focusDuration} minutes default focus'),
                      trailing: DropdownButton<int>(
                        value: provider.focusDuration,
                        underline: const SizedBox(),
                        items: [15, 20, 25, 30, 45, 50, 60]
                            .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) provider.setFocusDuration(val);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.alarm_rounded, color: AppColors.accentGreen),
                      title: const Text('Preferred Study Start'),
                      subtitle: Text(provider.preferredStudyStart),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        final parts = provider.preferredStudyStart.split(':');
                        final initialH = int.tryParse(parts.first) ?? 9;
                        final initialM = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: initialH, minute: initialM),
                        );
                        if (picked != null) {
                          final h = picked.hour.toString().padLeft(2, '0');
                          final m = picked.minute.toString().padLeft(2, '0');
                          provider.setPreferredStudyStart('$h:$m');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── App Appearance & Notifications ───────────────────────────────
            AppSection(
              title: 'Appearance & Notifications',
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.accentViolet,
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(provider.isDarkMode ? 'Deep OLED Dark theme' : 'Crisp Light theme'),
                      value: provider.isDarkMode,
                      onChanged: (_) => provider.toggleDarkMode(),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.accentAmber),
                      title: const Text('Study Reminders'),
                      subtitle: const Text('Daily schedules & exam countdowns'),
                      value: provider.notificationsEnabled,
                      onChanged: (val) => provider.setNotificationsEnabled(val),
                    ),
                  ],
                ),
              ),
            ),

            // ── Data & Portfolio Statistics ──────────────────────────────────
            AppSection(
              title: 'Workspace Data',
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'Subjects', value: '${provider.courses.length}'),
                        _StatItem(label: 'Tasks', value: '${provider.tasks.length}'),
                        _StatItem(label: 'Exams', value: '${provider.exams.length}'),
                        _StatItem(label: 'Notes', value: '${provider.notes.length}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                        label: const Text('Reset All Data', style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _confirmReset(context, provider),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Sign Out ─────────────────────────────────────────────────────
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight2,
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Study Planner Pro · Version 2.0.0',
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Study Data?'),
        content: const Text(
          'This will permanently delete all courses, topics, scheduled tasks, exams, and study notes.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.statMedium),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

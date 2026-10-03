import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/task_model.dart';
import '../../providers/app_provider.dart';
import '../focus/focus_screen.dart';
import '../tasks/add_task_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isGenerating = false;

  List<DateTime> get _days {
    final now = DateTime.now();
    return List.generate(14, (i) => DateTime(now.year, now.month, now.day + i));
  }

  Future<void> _generateSmartSchedule() async {
    setState(() => _isGenerating = true);
    final provider = context.read<AppProvider>();
    final count = await provider.generateSchedule();
    setState(() => _isGenerating = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? 'Smart Scheduler generated $count study sessions!'
                : 'All courses and topics are already up-to-date in schedule.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final tasksForDay = provider.tasksForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Timetable'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Add task for this day',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTaskScreen(initialDate: _selectedDate),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Smart Generation Banner ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.md,
              ),
              padding: const EdgeInsets.all(AppSpacing.card),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI-Powered Scheduler',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Balance workloads before upcoming exam deadlines',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isGenerating ? null : _generateSmartSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Auto-Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // ── Horizontal Date Selector ─────────────────────────────────────
            SizedBox(
              height: 76,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = day.year == _selectedDate.year &&
                      day.month == _selectedDate.month &&
                      day.day == _selectedDate.day;

                  final count = provider.tasksForDate(day).length;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(day).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(day),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (count > 0)
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Day Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(_selectedDate),
                    style: AppTextStyles.subtitle,
                  ),
                  const Spacer(),
                  Text(
                    '${tasksForDay.length} sessions',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Tasks / Schedule Timeline ────────────────────────────────────
            Expanded(
              child: tasksForDay.isEmpty
                  ? AppEmptyState(
                      icon: Icons.calendar_today_rounded,
                      title: 'No Sessions Scheduled',
                      message: 'Enjoy your free day or let the smart scheduler allocate study blocks!',
                      action: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome_rounded),
                        onPressed: _generateSmartSchedule,
                        label: const Text('Auto-Generate Schedule'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.sm,
                        AppSpacing.page,
                        AppSpacing.lg,
                      ),
                      itemCount: tasksForDay.length,
                      itemBuilder: (context, index) {
                        final task = tasksForDay[index];
                        return _TimetableTaskCard(task: task);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimetableTaskCard extends StatelessWidget {
  final StudyTask task;

  const _TimetableTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final course = provider.courses.cast<dynamic>().firstWhere(
          (c) => c.id == task.courseId,
          orElse: () => null,
        );

    final courseColor = course != null ? Color(course.colorValue) : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Checkbox(
              value: task.completed,
              activeColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: (_) => provider.toggleTask(task.id),
            ),
            const SizedBox(width: 8),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: courseColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course?.name ?? 'Subject',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: courseColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (task.isAutoGenerated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 10, color: AppColors.primary),
                              SizedBox(width: 3),
                              Text(
                                'Auto',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      PriorityBadge(priority: task.priority.name),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.title.isNotEmpty ? task.title : 'Study Session',
                    style: AppTextStyles.bodyBold.copyWith(
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                      color: task.completed
                          ? (isDark ? AppColors.mutedDark : AppColors.mutedLight)
                          : null,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(task.description, style: AppTextStyles.caption),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 14, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                      const SizedBox(width: 4),
                      Text(
                        '${task.duration.toStringAsFixed(1)}h planned',
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      // Start focus button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.play_circle_outline_rounded,
                            size: 16, color: AppColors.primary),
                        label: const Text(
                          'Focus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FocusScreen(initialCourseId: task.courseId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../providers/app_provider.dart';
import '../tasks/add_task_screen.dart';
import '../focus/focus_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final dayTasks = provider.tasksForDate(_selectedDate);

    // Days with tasks or exams in the current visible month
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday; // 1 = Mon

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Jump to today',
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTaskScreen(initialDate: _selectedDate),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Month Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: 8),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_visibleMonth),
                    style: AppTextStyles.hero.copyWith(fontSize: 22),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _changeMonth(-1),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),

            // ── Weekday Labels ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                  return SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // ── Calendar Grid ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 42, // 6 weeks
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  // Index offset by first weekday (1-indexed, Monday = 1)
                  final dayOffset = index - (firstWeekday - 1);
                  if (dayOffset < 0 || dayOffset >= daysInMonth) {
                    return const SizedBox();
                  }

                  final dayNum = dayOffset + 1;
                  final dayDate = DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
                  final isToday = dayDate.year == DateTime.now().year &&
                      dayDate.month == DateTime.now().month &&
                      dayDate.day == DateTime.now().day;
                  final isSelected = dayDate.year == _selectedDate.year &&
                      dayDate.month == _selectedDate.month &&
                      dayDate.day == _selectedDate.day;

                  final taskCount = provider.tasksForDate(dayDate).length;
                  final hasExam = provider.exams.any((e) =>
                      e.examDate.year == dayDate.year &&
                      e.examDate.month == dayDate.month &&
                      e.examDate.day == dayDate.day);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = dayDate),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isToday
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isToday
                                  ? AppColors.primary
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight)),
                          width: isSelected || isToday ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isToday ? AppColors.primary : null),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (taskCount > 0)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (hasExam)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : AppColors.accentRose,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),

            // ── Day Schedule Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                4,
              ),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(_selectedDate),
                    style: AppTextStyles.subtitle,
                  ),
                  const Spacer(),
                  Text(
                    '${dayTasks.length} task${dayTasks.length == 1 ? '' : 's'}',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // ── Selected Day Tasks ───────────────────────────────────────────
            Expanded(
              child: dayTasks.isEmpty
                  ? AppEmptyState(
                      icon: Icons.event_available_rounded,
                      title: 'No Tasks For This Date',
                      message: 'Schedule a study block or review session for this date.',
                      action: ElevatedButton.icon(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTaskScreen(initialDate: _selectedDate),
                          ),
                        ),
                        label: Text('Add Task for ${DateFormat('MMM d').format(_selectedDate)}'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        8,
                        AppSpacing.page,
                        80,
                      ),
                      itemCount: dayTasks.length,
                      itemBuilder: (context, index) {
                        final task = dayTasks[index];
                        final course = provider.courses.cast<dynamic>().firstWhere(
                              (c) => c.id == task.courseId,
                              orElse: () => null,
                            );
                        final courseColor =
                            course != null ? Color(course.colorValue) : AppColors.primary;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: task.completed,
                                  activeColor: AppColors.success,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  onChanged: (_) => provider.toggleTask(task.id),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: courseColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            course?.name ?? 'Subject',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: courseColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        task.title.isNotEmpty ? task.title : 'Study Task',
                                        style: AppTextStyles.bodyBold.copyWith(
                                          decoration: task.completed
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.play_circle_outline_rounded,
                                      color: AppColors.primary),
                                  tooltip: 'Focus on this task',
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FocusScreen(initialCourseId: task.courseId),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

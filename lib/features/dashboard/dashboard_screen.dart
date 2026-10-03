import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/task_model.dart';
import '../../providers/app_provider.dart';
import '../subjects/add_course_screen.dart';
import '../subjects/course_details_screen.dart';
import '../tasks/add_task_screen.dart';
import '../exams/add_exam_screen.dart';
import '../focus/focus_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final now = DateTime.now();
        final todayTasks = provider.tasksForDate(now);
        final completed = todayTasks.where((t) => t.completed).length;
        final remaining = todayTasks.length - completed;
        final todayProgress =
            todayTasks.isEmpty ? 0.0 : completed / todayTasks.length;
        final dailyGoal = provider.dailyHoursGoal;
        final todayHours = provider.todayStudyHours;
        final goalProgress = (todayHours / dailyGoal).clamp(0.0, 1.0);

        return Scaffold(
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.loadAll(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Hero Header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeroHeader(context, provider, todayProgress,
                      remaining, dailyGoal, todayHours, goalProgress),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, AppSpacing.lg,
                    AppSpacing.page, 0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Quick Stats ───────────────────────────────────────
                      _buildQuickStats(context, provider, todayTasks),
                      const SizedBox(height: AppSpacing.section),

                      // ── Quick Actions ──────────────────────────────────────
                      _buildQuickActions(context),
                      const SizedBox(height: AppSpacing.section),

                      // ── Today's Sessions ──────────────────────────────────
                      AppSection(
                        title: "Today's Schedule",
                        trailing: todayTasks.isNotEmpty
                            ? Text('$completed / ${todayTasks.length} done',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary))
                            : null,
                        child: todayTasks.isEmpty
                            ? _emptyScheduleCard(context)
                            : _buildTaskList(context, provider, todayTasks),
                      ),

                      // ── Upcoming Exams ────────────────────────────────────
                      if (provider.upcomingExams.isNotEmpty) ...[
                        AppSection(
                          title: 'Upcoming Exams',
                          child: _buildExamsList(context, provider),
                        ),
                      ],

                      // ── Course Progress ───────────────────────────────────
                      if (provider.activeCourses.isNotEmpty)
                        AppSection(
                          title: 'Subject Progress',
                          trailing: Text(
                              '${provider.activeCourses.length} active',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.primary)),
                          showDivider: false,
                          child: _buildCourseProgress(context, provider),
                        ),

                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Hero Header ────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(
    BuildContext context,
    AppProvider provider,
    double todayProgress,
    int remaining,
    double dailyGoal,
    double todayHours,
    double goalProgress,
  ) {
    final userName = _userName(context);
    final firstName = userName.split(' ').first;
    final greeting = _greeting();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        MediaQuery.of(context).padding.top + 20,
        AppSpacing.page,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: date + streak
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      _formattedDate(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.currentStreak} day streak',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Greeting
          Text(
            '$greeting, $firstName! 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            remaining == 0
                ? 'All tasks done for today! 🎉'
                : '$remaining task${remaining > 1 ? 's' : ''} remaining today.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Daily progress card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Daily Goal',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      '${todayHours.toStringAsFixed(1)}h / ${dailyGoal.toStringAsFixed(0)}h',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: goalProgress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(goalProgress * 100).toInt()}% complete',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Stats ────────────────────────────────────────────────────────────
  Widget _buildQuickStats(
      BuildContext context, AppProvider provider, List<StudyTask> todayTasks) {
    final completed = todayTasks.where((t) => t.completed).length;
    final overdue = provider.overdueTasks.length;
    final streak = provider.currentStreak;
    final weekHours = provider.weeklyStudyHours;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        StatCard(
          label: 'Completed Today',
          value: '$completed',
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.accentGreen,
        ),
        StatCard(
          label: 'Study Streak',
          value: '${streak}d 🔥',
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.accentAmber,
        ),
        StatCard(
          label: 'Week Hours',
          value: '${weekHours.toStringAsFixed(1)}h',
          icon: Icons.schedule_rounded,
          iconColor: AppColors.primary,
        ),
        StatCard(
          label: 'Overdue Tasks',
          value: '$overdue',
          icon: Icons.warning_amber_rounded,
          iconColor: overdue > 0 ? AppColors.accentRose : AppColors.mutedDark,
        ),
      ],
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _Action('Add Task', Icons.add_task_rounded, AppColors.primary, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()));
      }),
      _Action('Add Subject', Icons.menu_book_rounded, AppColors.accent, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddCourseScreen()));
      }),
      _Action('Focus Mode', Icons.timer_rounded, AppColors.accentRose, () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FocusScreen()));
      }),
      _Action('Add Exam', Icons.event_rounded, AppColors.accentAmber, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddExamScreen()));
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: actions
              .map((a) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _QuickActionButton(action: a),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ── Task List ──────────────────────────────────────────────────────────────
  Widget _buildTaskList(BuildContext context, AppProvider provider,
      List<StudyTask> tasks) {
    return Column(
      children: tasks.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TaskTile(
            task: task,
            provider: provider,
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyScheduleCard(BuildContext context) {
    return AppCard(
      child: AppEmptyState(
        icon: Icons.event_note_rounded,
        title: 'No sessions today',
        message:
            'Add subjects and topics, then generate a smart schedule from the Timetable tab.',
      ),
    );
  }

  // ── Exams List ─────────────────────────────────────────────────────────────
  Widget _buildExamsList(BuildContext context, AppProvider provider) {
    final exams = provider.upcomingExams.take(3).toList();
    return Column(
      children: exams.map((exam) {
        final course = provider.courses
            .where((c) => c.id == exam.courseId)
            .firstOrNull;
        final days = exam.daysUntilExam;
        final urgentColor = days <= 3
            ? AppColors.accentRose
            : days <= 7
                ? AppColors.accentAmber
                : AppColors.accentGreen;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: urgentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.event_rounded, color: urgentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.name, style: AppTextStyles.bodyMedium),
                      Text(
                        course?.name ?? 'Unknown Subject',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    days <= 0 ? 'Today!' : '${days}d',
                    style: AppTextStyles.label.copyWith(color: urgentColor),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Course Progress ────────────────────────────────────────────────────────
  Widget _buildCourseProgress(BuildContext context, AppProvider provider) {
    final courses = provider.activeCourses.take(4).toList();
    return Column(
      children: courses.map((course) {
        final topics = provider.topicsForCourse(course.id);
        final done = topics.where((t) => t.isCompleted).length;
        final progress = topics.isEmpty ? 0.0 : done / topics.length;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CourseDetailsScreen(courseId: course.id)),
            ),
            borderRadius: BorderRadius.circular(16),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: course.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book_rounded,
                        color: course.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(course.name,
                                  style: AppTextStyles.bodyMedium,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppProgressBar(value: progress, color: course.color, height: 5),
                        const SizedBox(height: 4),
                        Text(
                          '$done / ${topics.length} topics',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.mutedDark),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _userName(BuildContext context) {
    // Grab name from auth service via provider
    return 'Student'; // will be replaced in main wrapper
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

// ── Supporting widgets ──────────────────────────────────────────────────────

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _Action(this.label, this.icon, this.color, this.onTap);
}

class _QuickActionButton extends StatelessWidget {
  final _Action action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, size: 18, color: action.color),
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final StudyTask task;
  final AppProvider provider;
  const _TaskTile({required this.task, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDone = task.completed;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final course = provider.courses
        .where((c) => c.id == task.courseId)
        .firstOrNull;
    final courseColor = course?.color ?? AppColors.primary;
    final h = task.scheduledDate.hour;
    final m = task.scheduledDate.minute;
    final timeStr =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    final endH = task.scheduledDate.add(Duration(minutes: (task.duration * 60).toInt())).hour;
    final endM = task.scheduledDate.add(Duration(minutes: (task.duration * 60).toInt())).minute;
    final endStr = '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isDone
            ? (isDark ? AppColors.successBg : const Color(0xFFE8FFF3))
            : bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone ? AppColors.accentGreen.withValues(alpha: 0.3) : border,
        ),
      ),
      child: InkWell(
        onTap: () => provider.toggleTask(task.id),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Left color bar
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.accentGreen
                      : courseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              // Check
              GestureDetector(
                onTap: () => provider.toggleTask(task.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.accentGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDone
                          ? AppColors.accentGreen
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title.isNotEmpty
                          ? task.title
                          : (course?.name ?? 'Study Session'),
                      style: AppTextStyles.bodyMedium.copyWith(
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? AppColors.mutedDark : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$timeStr – $endStr · ${task.duration.toStringAsFixed(1)}h',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              PriorityBadge(priority: task.priority.name),
            ],
          ),
        ),
      ),
    );
  }
}

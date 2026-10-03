import 'dart:async';

import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../models/task_model.dart';
import '../../services/course_service.dart';
import '../../services/storage_change_notifier.dart';
import '../../services/notification_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_section.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/home/course_progress_row.dart';
import '../../widgets/home/deadline_row.dart';
import '../../widgets/home/task_row.dart';
import '../../widgets/home/today_summary.dart';
import '../courses/add_course_screen.dart';

import '../../features/home/main_navigation_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const MainNavigationShell();
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) => const MainNavigationShell();
}



class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<StudyTask> todayTasks = [];
  List<StudyTask> allTasks = [];
  List<Course> courses = [];
  bool isLoading = true;

  StreamSubscription<StorageChangeEvent>? _changeSub;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _changeSub = StorageChangeNotifier.instance.changes.listen((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _changeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    // Only show the loading spinner on the very first load.
    // Subsequent refreshes update data silently to avoid screen flashing.
    final isFirstLoad = isLoading;
    if (isFirstLoad && mounted) setState(() => isLoading = true);

    final results = await Future.wait([
      CourseService.getTasksForDate(DateTime.now()),
      CourseService.getAllTasks(),
      CourseService.getAllCourses(),
    ]);

    if (!mounted) return;

    setState(() {
      todayTasks = results[0] as List<StudyTask>;
      allTasks = results[1] as List<StudyTask>;
      courses = results[2] as List<Course>;
      isLoading = false;
    });

    NotificationService.checkAndNotifyUpcomingDeadlines(courses);
    NotificationService.checkAndNotifyPendingTasks();
  }

  Future<void> _toggleTask(StudyTask task) async {
    await CourseService.toggleTaskCompleted(task.id);
    await _loadDashboardData();
  }

  Future<void> _quickAddCourse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCourseScreen()),
    );
    if (result == true) await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final completed = todayTasks.where((t) => t.completed).length;
    final studied = todayTasks
        .where((t) => t.completed)
        .fold<double>(0, (sum, t) => sum + t.duration);
    final remaining = todayTasks
        .where((t) => !t.completed)
        .fold<double>(0, (sum, t) => sum + t.duration);
    final upcoming = [...courses]
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      backgroundColor: AppColors.background,
<<<<<<< HEAD
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Study Planner',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              NotificationService.showNotification(
                id: 100,
                title: 'Study Planner',
                body: 'Your study goals are on track!',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications active.')),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 900 ? 760.0 : double.infinity;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                  child: isLoading
                      ? const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TodaySummary(
                        completed: completed,
                        total: todayTasks.length,
                        studiedHours: studied,
                        remainingHours: remaining,
                      ),
                      const SizedBox(height: 24),
                      AppSection(
                        title: "Today's Tasks",
                        trailing: todayTasks.isNotEmpty
                            ? Text(
                          '${todayTasks.length} ${todayTasks.length == 1 ? 'task' : 'tasks'}',
                          style: AppTextStyles.muted,
                        )
                            : null,
                        child: todayTasks.isEmpty
                            ? const EmptyState(
                          icon: Icons.checklist_outlined,
                          title: 'No tasks for today',
                          message:
                          'Your schedule is clear for today.',
                        )
                            : Column(
                          children: todayTasks
                              .map(
                                (task) => TaskRow(
                              task: task,
                              onChanged: () => _toggleTask(task),
                            ),
                          )
                              .toList(),
                        ),
                      ),
                      AppSection(
                        title: 'Upcoming Deadlines',
                        trailing: upcoming.isNotEmpty
                            ? Text(
                                '${upcoming.length} ${upcoming.length == 1 ? 'course' : 'courses'}',
                                style: AppTextStyles.muted,
                              )
                            : null,
                        dividerAfter: courses.isNotEmpty,
                        child: upcoming.isEmpty
                            ? const Text(
                                'No upcoming deadlines.',
                                style: AppTextStyles.muted,
                              )
                            : Column(
                                children: upcoming
                                    .take(4)
                                    .map((course) => DeadlineRow(course: course))
                                    .toList(),
                              ),
                      ),
                      if (courses.isNotEmpty)
                        AppSection(
                          title: 'Course Progress',
                          dividerAfter: false,
                          child: Column(
                            children: courses
                                .take(4)
                                .map(
                                  (course) => CourseProgressRow(
                                    course: course,
                                    tasks: allTasks,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
=======
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 900 ? 760.0 : double.infinity;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      18,
                      AppSpacing.page,
                      40,
                    ),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Greeting Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x244F46E5),
                                      blurRadius: 18,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.bolt, size: 14, color: Colors.amberAccent),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formattedToday(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: _quickAddCourse,
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.add, size: 15, color: AppColors.primary),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Add Course',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Good ${_dayPart()}, $firstName 👋',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      todayTasks.isEmpty
                                          ? 'Your schedule is clear today. Ready to build a new study plan?'
                                          : 'You have ${todayTasks.length - completed} tasks left to accomplish today. Let\'s conquer them!',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Today's Summary
                              AppSection(
                                title: "Today's Focus",
                                child: TodaySummary(
                                  completed: completed,
                                  total: todayTasks.length,
                                  studiedHours: studied,
                                  remainingHours: remaining,
                                ),
                              ),

                              // Today's Tasks
                              AppSection(
                                title: "Scheduled For Today",
                                trailing: todayTasks.isNotEmpty
                                    ? Text(
                                        '$completed / ${todayTasks.length} done',
                                        style: AppTextStyles.muted,
                                      )
                                    : null,
                                child: todayTasks.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.cardBorder),
                                        ),
                                        child: const EmptyState(
                                          icon: Icons.checklist_outlined,
                                          title: 'No study sessions today',
                                          message: 'Add topics to your courses to generate your personalized timetable.',
                                        ),
                                      )
                                    : Column(
                                        children: todayTasks
                                            .map(
                                              (task) => TaskRow(
                                                task: task,
                                                onChanged: () => _toggleTask(task),
                                              ),
                                            )
                                            .toList(),
                                      ),
                              ),

                              // Course Progress
                              AppSection(
                                title: 'Course Milestones',
                                trailing: courses.isNotEmpty
                                    ? Text('${courses.length} total', style: AppTextStyles.muted)
                                    : null,
                                child: courses.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.cardBorder),
                                        ),
                                        child: const Text(
                                          'No active courses found. Tap "+ Add Course" at the top to get started!',
                                          style: AppTextStyles.muted,
                                        ),
                                      )
                                    : Column(
                                        children: courses
                                            .take(5)
                                            .map(
                                              (course) => CourseProgressRow(
                                                course: course,
                                                tasks: allTasks,
                                              ),
                                            )
                                            .toList(),
                                      ),
                              ),

                              // Upcoming Deadlines
                              AppSection(
                                title: 'Upcoming Deadlines',
                                dividerAfter: false,
                                child: upcoming.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.cardBorder),
                                        ),
                                        child: const Text(
                                          'No upcoming deadlines found.',
                                          style: AppTextStyles.muted,
                                        ),
                                      )
                                    : Column(
                                        children: upcoming
                                            .take(4)
                                            .map((course) => DeadlineRow(course: course))
                                            .toList(),
                                      ),
                              ),
                            ],
                          ),
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  }

<<<<<<< HEAD
=======
  String _formattedToday() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _dayPart() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
}
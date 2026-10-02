import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../models/task_model.dart';
import '../../services/course_service.dart';
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
import '../calender/calender_screen.dart';
import '../courses/courses_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppShell();
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  static const pages = [
    HomeContent(),
    CoursesScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) setState(() => isLoading = true);

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
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  }

}
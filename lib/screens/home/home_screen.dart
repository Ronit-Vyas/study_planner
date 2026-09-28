import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
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
    final userName = AuthService.currentUser?.name ?? 'Student';
    final firstName = userName.trim().split(RegExp(r'\s+')).first;
    final completed = todayTasks.where((t) => t.completed).length;
    final studied = todayTasks
        .where((t) => t.completed)
        .fold<double>(0, (sum, t) => sum + t.duration);
    final remaining = todayTasks
        .where((t) => !t.completed)
        .fold<double>(0, (sum, t) => sum + t.duration);
    final upcoming = [...courses]
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return RefreshIndicator(
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
                      Text(
                        'Good ${_dayPart()}, $firstName',
                        style: AppTextStyles.display,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Here's your study overview",
                        style: AppTextStyles.muted,
                      ),
                      const SizedBox(height: AppSpacing.section),
                      AppSection(
                        title: 'Today',
                        child: TodaySummary(
                          completed: completed,
                          total: todayTasks.length,
                          studiedHours: studied,
                          remainingHours: remaining,
                        ),
                      ),
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
                        title: 'Course Progress',
                        child: courses.isEmpty
                            ? const Text(
                          'No courses yet. Add your first course from the Courses tab.',
                          style: AppTextStyles.muted,
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
                      AppSection(
                        title: 'Upcoming',
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
                        dividerAfter: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _dayPart() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/task_card.dart';
import '../calender/calender_screen.dart';
import '../courses/add_course_screen.dart';
import '../courses/courses_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final screens = const [
    HomeContent(),
    CalendarScreen(),
    CoursesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Planner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    final now = DateTime.now();
    final tasks = await CourseService.getTasksForDate(now);
    final courses = await CourseService.getAllCourses();

    if (!mounted) return;

    setState(() {
      todayTasks = tasks;
      isLoading = false;
    });

    // Check deadlines and pending reminders in background
    NotificationService.checkAndNotifyUpcomingDeadlines(courses);
    NotificationService.checkAndNotifyPendingTasks();
  }

  Future<void> _toggleTask(StudyTask task) async {
    await CourseService.toggleTaskCompleted(task.id);
    await _loadDashboardData();
  }

  Future<void> _openAddCourse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddCourseScreen(),
      ),
    );

    if (result == true) {
      await _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.currentUser?.name ?? 'Student';
    final completedCount = todayTasks.where((t) => t.completed).length;
    final totalCount = todayTasks.length;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Hello, $userName 👋',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s make today productive with your study goals.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 25),

            // Progress Card
            _buildProgressCard(completedCount, totalCount, progress),

            const SizedBox(height: 30),

            // Today's Tasks Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Tasks',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalCount > 0)
                  Text(
                    '$completedCount of $totalCount completed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (todayTasks.isEmpty)
              _buildEmptyTaskCard()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayTasks.length,
                itemBuilder: (context, index) {
                  final task = todayTasks[index];
                  return TaskCard(
                    task: task,
                    onChanged: () => _toggleTask(task),
                  );
                },
              ),

            const SizedBox(height: 25),

            // Add Course Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _openAddCourse,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Course',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(int completed, int total, double progress) {
    final percentText = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$percentText%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '$completed / $total Tasks Completed',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total > 0 ? progress : 0,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          Text(
            'No tasks for today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a course and topics to generate your daily study schedule.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
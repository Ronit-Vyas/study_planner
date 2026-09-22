import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/course_service.dart';
import '../../widgets/task_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  List<StudyTask> dayTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasksForDate(selectedDate);
  }

  Future<void> _loadTasksForDate(DateTime date) async {
    setState(() {
      isLoading = true;
    });

    final tasks = await CourseService.getTasksForDate(date);

    if (!mounted) return;
    setState(() {
      selectedDate = date;
      dayTasks = tasks;
      isLoading = false;
    });
  }

  Future<void> _toggleTask(StudyTask task) async {
    await CourseService.toggleTaskCompleted(task.id);
    await _loadTasksForDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = dayTasks.where((t) => t.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  onDateChanged: (date) {
                    _loadTasksForDate(date);
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: [
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dayTasks.isEmpty
                            ? '0 tasks'
                            : '$completedCount / ${dayTasks.length} done',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (dayTasks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No study tasks scheduled for this day.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final task = dayTasks[index];
                    return TaskCard(
                      task: task,
                      onChanged: () => _toggleTask(task),
                    );
                  },
                  childCount: dayTasks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
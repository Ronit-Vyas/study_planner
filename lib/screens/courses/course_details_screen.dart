import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../models/topic_model.dart';
import '../../services/course_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/scheduler_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/priority_badge.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  const CourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  List<Topic> topics = [];
  bool isLoading = true;
  double courseProgress = 0.0;
  int completedTasksCount = 0;
  int totalTasksCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTopicsAndProgress();
  }

  Future<void> _loadTopicsAndProgress() async {
    setState(() {
      isLoading = true;
    });

    final loadedTopics =
        await CourseService.getTopicsForCourse(widget.course.id);
    final allTasks = await CourseService.getAllTasks();
    final courseTasks =
        allTasks.where((t) => t.courseId == widget.course.id).toList();

    double progress = 0.0;
    int completed = 0;
    if (courseTasks.isNotEmpty) {
      completed = courseTasks.where((t) => t.completed).length;
      progress = completed / courseTasks.length;
    }

    if (!mounted) return;

    setState(() {
      topics = loadedTopics;
      courseProgress = progress;
      completedTasksCount = completed;
      totalTasksCount = courseTasks.length;
      isLoading = false;
    });
  }

  Future<void> _showAddTopicDialog() async {
    final nameCtrl = TextEditingController();
    final hoursCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Topic Name',
                hintText: 'e.g. Binary Trees',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hoursCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Estimated Hours',
                hintText: 'e.g. 3.5',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      final hours = double.tryParse(hoursCtrl.text.trim()) ?? 1.0;
      final topic = Topic(
        id: 'topic_${DateTime.now().millisecondsSinceEpoch}',
        courseId: widget.course.id,
        name: nameCtrl.text.trim(),
        estimatedHours: hours,
      );

      await CourseService.addTopic(topic);
      await _loadTopicsAndProgress();
    }
  }

  Future<void> _generateSchedule() async {
    if (topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one topic before generating a schedule.'),
        ),
      );
      return;
    }

    final dailyHours = await LocalStorageService.getDailyStudyHours();
    final allCourses = await CourseService.getAllCourses();
    final allTopics = await LocalStorageService.getAllTopics();

    final newTasks = SchedulerService.generateSchedule(
      courses: allCourses,
      topics: allTopics,
      hoursPerDay: dailyHours,
    );

    await CourseService.saveTasks(newTasks);
    await _loadTopicsAndProgress();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generated ${newTasks.length} study tasks stored locally on your device!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = widget.course.deadline.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PriorityBadge(
                    priority: widget.course.priority,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.course.description.isEmpty
                  ? 'No description provided.'
                  : widget.course.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            _infoCard(
              Icons.calendar_month,
              'Deadline',
              formatDate(widget.course.deadline),
            ),
            _infoCard(
              Icons.access_time,
              'Estimated Time',
              '${widget.course.estimatedHours} hours',
            ),
            _infoCard(
              Icons.timer_outlined,
              'Days Remaining',
              daysLeft < 0 ? 'Deadline passed' : '$daysLeft days',
            ),
            const SizedBox(height: 20),
            const Text(
              'Study Progress',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: courseProgress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Text(
              totalTasksCount > 0
                  ? '${(courseProgress * 100).toInt()}% completed ($completedTasksCount of $totalTasksCount tasks)'
                  : '0% completed (no tasks scheduled yet)',
            ),
            const SizedBox(height: 30),

            // Topics Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Topics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddTopicDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Topic'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (topics.isEmpty)
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No topics added yet. Add topics to break down this course.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(topic.name),
                      subtitle: Text('${topic.estimatedHours} hours estimated'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          await CourseService.deleteTopic(topic.id);
                          await _loadTopicsAndProgress();
                        },
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 25),

            // Generate Schedule Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _generateSchedule,
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  'Generate Study Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
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

  Widget _infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
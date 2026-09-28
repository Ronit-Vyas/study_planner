import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../models/topic_model.dart';
import '../../services/course_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/scheduler_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_section.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/courses/priority_badge.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;
  const CourseDetailsScreen({super.key, required this.course});
  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  List<Topic> topics = [];
  double courseProgress = 0;
  int completedTasks = 0;
  int totalTasks = 0;
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() => loading = true);
    final results = await Future.wait([CourseService.getTopicsForCourse(widget.course.id), CourseService.getAllTasks()]);
    final loadedTopics = results[0] as List<Topic>;
    final allTasks = results[1] as List;
    final tasks = allTasks.where((t) => t.courseId == widget.course.id).toList();
    final done = tasks.where((t) => t.completed).length;
    if (!mounted) return;
    setState(() { topics = loadedTopics; completedTasks = done; totalTasks = tasks.length; courseProgress = tasks.isEmpty ? 0 : done / tasks.length; loading = false; });
  }

  Future<void> _addTopic() async {
    final nameCtrl = TextEditingController();
    final hoursCtrl = TextEditingController();
    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Add topic'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Topic name')), const SizedBox(height: 12), TextField(controller: hoursCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Estimated hours'))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add topic'))]));
    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      await CourseService.addTopic(Topic(id: 'topic_${DateTime.now().millisecondsSinceEpoch}', courseId: widget.course.id, name: nameCtrl.text.trim(), estimatedHours: double.tryParse(hoursCtrl.text.trim()) ?? 1));
      await _load();
    }
    nameCtrl.dispose(); hoursCtrl.dispose();
  }

  Future<void> _deleteTopic(Topic topic) async { await CourseService.deleteTopic(topic.id); await _load(); }

  Future<void> _generateSchedule() async {
    if (topics.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one topic before generating a schedule.'))); return; }
    final dailyHours = await LocalStorageService.getDailyStudyHours();
    final courses = await CourseService.getAllCourses();
    final allTopics = await LocalStorageService.getAllTopics();
    final tasks = SchedulerService.generateSchedule(courses: courses, topics: allTopics, hoursPerDay: dailyHours);
    await CourseService.saveTasks(tasks);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generated ${tasks.length} study tasks.')));
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = widget.course.deadline.difference(DateTime.now()).inDays;
    final totalTopicHours = topics.fold<double>(0, (sum, topic) => sum + topic.estimatedHours);
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)), title: const Text('Course Details')),
      body: SingleChildScrollView(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.page, 8, AppSpacing.page, 36), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.course.name, style: AppTextStyles.display),
        const SizedBox(height: 7),
        Row(children: [PriorityBadge(priority: widget.course.priority), const SizedBox(width: 10), Text(daysLeft < 0 ? 'Deadline passed · ${formatDate(widget.course.deadline)}' : '$daysLeft days left · ${formatDate(widget.course.deadline)}', style: AppTextStyles.muted)]),
        const SizedBox(height: AppSpacing.section),
        Row(children: [Expanded(child: Text('${(courseProgress * 100).round()}%', style: AppTextStyles.display.copyWith(color: AppColors.primary))), Text('$completedTasks / $totalTasks tasks', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700))]),
        const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: courseProgress, minHeight: 7)),
        const SizedBox(height: 8), Text('${widget.course.estimatedHours.toStringAsFixed(1)}h course estimate · ${totalTopicHours.toStringAsFixed(1)}h across topics', style: AppTextStyles.muted),
        const SizedBox(height: AppSpacing.section),
        AppSection(title: 'Overview', child: Column(children: [_metric('Deadline', formatDate(widget.course.deadline)), _metric('Estimated time', '${widget.course.estimatedHours.toStringAsFixed(1)}h'), _metric('Topics', '${topics.length}')])),
        AppSection(title: 'Topics', trailing: TextButton.icon(onPressed: _addTopic, icon: const Icon(Icons.add, size: 17), label: const Text('Add topic')), child: loading ? const Center(child: CircularProgressIndicator()) : topics.isEmpty ? const EmptyState(icon: Icons.topic_outlined, title: 'No topics yet', message: 'Break the course into smaller study topics to generate a schedule.') : Column(children: [for (int i = 0; i < topics.length; i++) ...[Row(children: [SizedBox(width: 24, child: Text('${i + 1}', style: AppTextStyles.muted.copyWith(fontWeight: FontWeight.w700))), Expanded(child: Text(topics[i].name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))), Text('${topics[i].estimatedHours.toStringAsFixed(topics[i].estimatedHours % 1 == 0 ? 0 : 1)}h', style: AppTextStyles.muted), IconButton(onPressed: () => _deleteTopic(topics[i]), icon: const Icon(Icons.delete_outline, size: 19, color: AppColors.error))]), if (i != topics.length - 1) const Divider()]]), dividerAfter: false),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _generateSchedule, icon: const Icon(Icons.auto_awesome, size: 18), label: const Text('Generate study schedule'))),
      ]))))),
    );
  }

  Widget _metric(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(label, style: AppTextStyles.muted)), Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700))]));
}

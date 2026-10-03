import 'package:flutter/material.dart';
import '../../data/models/course_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/models/task_model.dart';
import '../../services/course_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/scheduler_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
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
  List<StudyTask> tasks = [];
  double courseProgress = 0;
  int completedTasks = 0;
  int totalTasks = 0;
  bool loading = true;
  bool isGenerating = false;

  // Inline topic quick-add
  final quickTopicController = TextEditingController();
  double quickTopicHours = 2.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    quickTopicController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => loading = true);
    final results = await Future.wait([
      CourseService.getTopicsForCourse(widget.course.id),
      CourseService.getAllTasks(),
    ]);

    final loadedTopics = results[0] as List<Topic>;
    final allTasks = results[1] as List<StudyTask>;
    final courseTasks = allTasks.where((t) => t.courseId == widget.course.id).toList();
    final done = courseTasks.where((t) => t.completed).length;

    if (!mounted) return;
    setState(() {
      topics = loadedTopics;
      tasks = courseTasks;
      completedTasks = done;
      totalTasks = courseTasks.length;
      courseProgress = courseTasks.isEmpty ? 0 : done / courseTasks.length;
      loading = false;
    });
  }

  Future<void> _addTopicInline() async {
    final name = quickTopicController.text.trim();
    if (name.isEmpty) return;

    final newTopic = Topic(
      id: 'topic_${DateTime.now().millisecondsSinceEpoch}',
      courseId: widget.course.id,
      name: name,
      estimatedHours: quickTopicHours,
    );

    await CourseService.addTopic(newTopic);
    quickTopicController.clear();
    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$name" (${quickTopicHours}h)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteTopic(Topic topic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete topic?'),
        content: Text('Delete "${topic.name}" and any associated tasks?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CourseService.deleteTopic(topic.id);
      await _load();
    }
  }

  Future<void> _generateSchedule() async {
    if (topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one topic before generating a schedule.')),
      );
      return;
    }

    setState(() => isGenerating = true);

    try {
      final dailyHours = await LocalStorageService.getDailyStudyHours();
      final courses = await CourseService.getAllCourses();
      final allTopics = await LocalStorageService.getAllTopics();
      final generatedTasks = SchedulerService.generateSchedule(
        courses: courses,
        topics: allTopics,
        hoursPerDay: dailyHours,
      );

      await CourseService.saveTasks(generatedTasks);
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generated ${generatedTasks.length} study tasks successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = widget.course.deadline.difference(DateTime.now()).inDays;
    final totalTopicHours = topics.fold<double>(0, (sum, topic) => sum + topic.estimatedHours);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Course Details'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.page, 10, AppSpacing.page, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x080F172A),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.course.name, style: AppTextStyles.hero.copyWith(fontSize: 22)),
                                        if (widget.course.description.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(widget.course.description, style: AppTextStyles.muted),
                                        ],
                                      ],
                                    ),
                                  ),
                                  PriorityBadge(priority: widget.course.priority),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Progress Bar with Stats
                              Row(
                                children: [
                                  Text(
                                    '${(courseProgress * 100).round()}% Completed',
                                    style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$completedTasks of $totalTasks study tasks finished',
                                    style: AppTextStyles.muted,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: courseProgress,
                                  minHeight: 8,
                                  backgroundColor: AppColors.surfaceSubtle,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Metrics Grid
                              Row(
                                children: [
                                  _metricChip(
                                    Icons.event_outlined,
                                    'Deadline',
                                    daysLeft < 0 ? 'Overdue' : '$daysLeft days left',
                                    daysLeft <= 2 ? AppColors.warning : AppColors.text,
                                  ),
                                  const SizedBox(width: 8),
                                  _metricChip(
                                    Icons.access_time_rounded,
                                    'Estimate',
                                    '${widget.course.estimatedHours.toStringAsFixed(1)}h',
                                    AppColors.text,
                                  ),
                                  const SizedBox(width: 8),
                                  _metricChip(
                                    Icons.layers_outlined,
                                    'Topics',
                                    '${topics.length} topics',
                                    AppColors.text,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Schedule Banner if tasks are empty
                        if (tasks.isEmpty && topics.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Daily Plan Not Generated Yet',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Generate your schedule to distribute topics across your calendar days.',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: isGenerating ? null : _generateSchedule,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                  child: const Text('Generate Now'),
                                ),
                              ],
                            ),
                          ),

                        // Topics Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('COURSE TOPICS', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${topics.length} topics · ${totalTopicHours.toStringAsFixed(1)}h planned',
                                          style: AppTextStyles.muted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Quick Inline Add Topic
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: quickTopicController,
                                        textCapitalization: TextCapitalization.sentences,
                                        onSubmitted: (_) => _addTopicInline(),
                                        decoration: const InputDecoration(
                                          hintText: 'Add new topic (e.g. Chapter 3: Trees)...',
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.cardBorder),
                                      ),
                                      child: DropdownButton<double>(
                                        value: quickTopicHours,
                                        underline: const SizedBox(),
                                        items: const [
                                          DropdownMenuItem(value: 0.5, child: Text('0.5h')),
                                          DropdownMenuItem(value: 1.0, child: Text('1.0h')),
                                          DropdownMenuItem(value: 1.5, child: Text('1.5h')),
                                          DropdownMenuItem(value: 2.0, child: Text('2.0h')),
                                          DropdownMenuItem(value: 3.0, child: Text('3.0h')),
                                          DropdownMenuItem(value: 4.0, child: Text('4.0h')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => quickTopicHours = val);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _addTopicInline,
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(42, 42),
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                      ),
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              if (topics.isEmpty)
                                const EmptyState(
                                  icon: Icons.topic_outlined,
                                  title: 'No topics yet',
                                  message: 'Type a topic above to break this course into manageable study sessions.',
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: topics.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final topic = topics[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 26,
                                            height: 26,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              topic.name,
                                              style: AppTextStyles.bodyBold,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceSubtle,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${topic.estimatedHours.toStringAsFixed(topic.estimatedHours % 1 == 0 ? 0 : 1)}h',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _deleteTopic(topic),
                                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isGenerating ? null : _generateSchedule,
                            icon: isGenerating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.auto_awesome, size: 20),
                            label: Text(
                              tasks.isEmpty ? 'Generate Study Schedule' : 'Regenerate Study Schedule',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _metricChip(IconData icon, String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.mutedText),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedText, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}

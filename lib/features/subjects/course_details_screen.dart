import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/course_model.dart';
import '../../data/models/topic_model.dart';
import '../../providers/app_provider.dart';
import 'add_course_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final course = provider.courses
            .where((c) => c.id == widget.courseId)
            .firstOrNull;
        if (course == null) {
          return const Scaffold(
            body: Center(child: Text('Course not found')),
          );
        }

        final topics = provider.topicsForCourse(course.id);
        final done = topics.where((t) => t.isCompleted).length;
        final progress = topics.isEmpty ? 0.0 : done / topics.length;
        final exams = provider.examsForCourse(course.id);
        final tasks = provider.tasksForCourse(course.id);
        final notes = provider.notesForCourse(course.id);

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddCourseScreen(existing: course)),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeroHeader(course, progress, done, topics.length),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabDelegate(
                  TabBar(
                    controller: _tab,
                    indicatorColor: course.color,
                    labelColor: course.color,
                    unselectedLabelColor: AppColors.mutedDark,
                    tabs: const [
                      Tab(text: 'Topics'),
                      Tab(text: 'Details'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tab,
              children: [
                _buildTopicsTab(context, provider, course, topics),
                _buildDetailsTab(context, provider, course, exams, tasks, notes),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addTopic(context, provider, course),
            backgroundColor: course.color,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(
      Course course, double progress, int done, int total) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [course.color, course.color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            course.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (course.description.isNotEmpty)
            Text(course.description,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$done / $total topics completed',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsTab(BuildContext context, AppProvider provider,
      Course course, List<Topic> topics) {
    if (topics.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AppEmptyState(
          icon: Icons.list_alt_rounded,
          title: 'No topics yet',
          message: 'Add topics to break down your subject and generate a smart study schedule.',
          action: ElevatedButton.icon(
            onPressed: () => _addTopic(context, provider, course),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Topic'),
            style: ElevatedButton.styleFrom(backgroundColor: course.color),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.md, AppSpacing.page, 100),
      itemCount: topics.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _TopicTile(
        topic: topics[i],
        courseColor: course.color,
        provider: provider,
        onEdit: () => _editTopic(context, provider, course, topics[i]),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, AppProvider provider,
      Course course, exams, tasks, notes) {
    final days = course.daysUntilDeadline;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              StatCard(
                label: 'Estimated Hours',
                value: '${course.estimatedHours.toInt()}h',
                icon: Icons.schedule_rounded,
                iconColor: course.color,
              ),
              StatCard(
                label: 'Days Remaining',
                value: days < 0 ? 'Overdue' : '${days}d',
                icon: Icons.timer_rounded,
                iconColor:
                    days < 3 ? AppColors.accentRose : AppColors.accentGreen,
              ),
              StatCard(
                label: 'Priority',
                value: course.priority.substring(0, 1).toUpperCase() +
                    course.priority.substring(1),
                icon: Icons.flag_rounded,
                iconColor: AppColors.medium,
              ),
              StatCard(
                label: 'Difficulty',
                value: course.difficulty.name.substring(0, 1).toUpperCase() +
                    course.difficulty.name.substring(1),
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Exams
          Text('Exams', style: AppTextStyles.subtitle),
          const SizedBox(height: 10),
          if (exams.isEmpty)
            const Text('No exams added.', style: TextStyle(color: AppColors.mutedDark))
          else
            ...exams.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded,
                            color: AppColors.accentAmber, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(e.name, style: AppTextStyles.bodyMedium),
                        ),
                        Text(
                          '${e.daysUntilExam}d',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _addTopic(BuildContext context, AppProvider provider, Course course) {
    _showTopicSheet(context, provider, course, null);
  }

  void _editTopic(
      BuildContext context, AppProvider provider, Course course, Topic t) {
    _showTopicSheet(context, provider, course, t);
  }

  void _showTopicSheet(BuildContext context, AppProvider provider,
      Course course, Topic? existing) {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final hoursCtrl = TextEditingController(
        text: existing?.estimatedHours.toStringAsFixed(1) ?? '2.0');
    String priority = existing?.priority ?? 'medium';
    int difficulty = existing?.difficulty ?? 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Add Topic' : 'Edit Topic',
                  style: AppTextStyles.title),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Topic Name *',
                  hintText: 'e.g. Integration, Sorting Algorithms',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hoursCtrl,
                decoration: const InputDecoration(
                  labelText: 'Estimated Hours',
                  prefixIcon: Icon(Icons.schedule_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: course.color),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final hours =
                            double.tryParse(hoursCtrl.text) ?? 2.0;

                        if (existing == null) {
                          await provider.addTopic(Topic(
                            id: const Uuid().v4(),
                            courseId: course.id,
                            name: name,
                            estimatedHours: hours,
                            priority: priority,
                            difficulty: difficulty,
                          ));
                        } else {
                          await provider.updateTopic(existing.copyWith(
                            name: name,
                            estimatedHours: hours,
                            priority: priority,
                            difficulty: difficulty,
                          ));
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child:
                          Text(existing == null ? 'Add Topic' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Topic tile ─────────────────────────────────────────────────────────────

class _TopicTile extends StatelessWidget {
  final Topic topic;
  final Color courseColor;
  final AppProvider provider;
  final VoidCallback onEdit;

  const _TopicTile({
    required this.topic,
    required this.courseColor,
    required this.provider,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final statusColor = topic.isCompleted
        ? AppColors.accentGreen
        : topic.isInProgress
            ? AppColors.accentAmber
            : AppColors.mutedDark;

    final statusIcon = topic.isCompleted
        ? Icons.check_circle_rounded
        : topic.isInProgress
            ? Icons.pending_rounded
            : Icons.radio_button_unchecked_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _cycleStatus(context),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    decoration: topic.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: topic.isCompleted ? AppColors.mutedDark : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('${topic.estimatedHours}h',
                        style: AppTextStyles.caption),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        topic.statusLabel,
                        style: AppTextStyles.label
                            .copyWith(color: statusColor, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 18),
            onSelected: (v) async {
              switch (v) {
                case 'edit':
                  onEdit();
                  break;
                case 'complete':
                  await provider.markTopicCompleted(topic.id);
                  break;
                case 'delete':
                  await provider.deleteTopic(topic.id);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              if (!topic.isCompleted)
                const PopupMenuItem(
                    value: 'complete', child: Text('Mark Complete')),
              const PopupMenuItem(
                  value: 'delete',
                  child:
                      Text('Delete', style: TextStyle(color: AppColors.error))),
            ],
          ),
        ],
      ),
    );
  }

  void _cycleStatus(BuildContext context) {
    final next = topic.isNotStarted
        ? TopicStatus.inProgress
        : topic.isInProgress
            ? TopicStatus.completed
            : TopicStatus.notStarted;
    provider.updateTopic(topic.copyWith(status: next));
  }
}

// ── Tab delegate ────────────────────────────────────────────────────────────

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.bgDark : AppColors.bgLight,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabDelegate old) => old.tabBar != tabBar;
}

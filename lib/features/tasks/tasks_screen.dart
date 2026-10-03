import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/task_model.dart';
import '../../providers/app_provider.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _search = '';
  String _sortBy = 'deadline';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, AppSpacing.lg, AppSpacing.page, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tasks', style: AppTextStyles.hero),
                      Consumer<AppProvider>(
                        builder: (_, p, _) => Text(
                          '${p.pendingTasks.length} pending · ${p.overdueTasks.length} overdue',
                          style: AppTextStyles.muted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort_rounded),
                    onSelected: (v) => setState(() => _sortBy = v),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'deadline', child: Text('Sort by Deadline')),
                      const PopupMenuItem(value: 'priority', child: Text('Sort by Priority')),
                      const PopupMenuItem(value: 'created', child: Text('Sort by Date Created')),
                    ],
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page, vertical: 4),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.mutedDark, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            TabBar(
              controller: _tab,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.mutedDark,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildList(context, 'all'),
                  _buildList(context, 'pending'),
                  _buildList(context, 'completed'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildList(BuildContext context, String filter) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        var tasks = [...provider.tasks];

        // Tab filter
        if (filter == 'pending') {
          tasks = tasks.where((t) => !t.completed).toList();
        } else if (filter == 'completed') {
          tasks = tasks.where((t) => t.completed).toList();
        }

        // Search
        if (_search.isNotEmpty) {
          tasks = tasks.where((t) =>
              t.title.toLowerCase().contains(_search.toLowerCase()) ||
              t.description.toLowerCase().contains(_search.toLowerCase())).toList();
        }

        // Sort
        switch (_sortBy) {
          case 'deadline':
            tasks.sort((a, b) {
              if (a.deadline == null && b.deadline == null) return 0;
              if (a.deadline == null) return 1;
              if (b.deadline == null) return -1;
              return a.deadline!.compareTo(b.deadline!);
            });
            break;
          case 'priority':
            tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
            break;
          case 'created':
            tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
        }

        if (tasks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppEmptyState(
              icon: Icons.checklist_rounded,
              title: filter == 'completed'
                  ? 'No completed tasks'
                  : 'No tasks yet',
              message: 'Add tasks to track your study sessions and stay on top of your schedule.',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.md, AppSpacing.page, 100),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) =>
              _TaskCard(task: tasks[i], provider: provider),
        );
      },
    );
  }
}

// ── Task Card ──────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final StudyTask task;
  final AppProvider provider;

  const _TaskCard({required this.task, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final course = provider.courses
        .where((c) => c.id == task.courseId)
        .firstOrNull;
    final courseColor = course?.color ?? AppColors.primary;
    final isDone = task.completed;
    final isOverdue = task.isOverdue;

    final (Color indicatorColor) = isOverdue
        ? AppColors.error
        : isDone
            ? AppColors.accentGreen
            : courseColor;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => provider.deleteTask(task.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone
              ? (isDark ? AppColors.successBg : const Color(0xFFE8FFF3))
              : bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? AppColors.accentGreen.withValues(alpha: 0.4)
                : isOverdue
                    ? AppColors.error.withValues(alpha: 0.4)
                    : border,
          ),
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),

            // Checkbox
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
                    color: isDone ? AppColors.accentGreen : border,
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
                    task.title.isNotEmpty ? task.title : 'Study Session',
                    style: AppTextStyles.bodyMedium.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AppColors.mutedDark : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (course != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: courseColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(course.name,
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                      ],
                      if (isOverdue)
                        Text('OVERDUE',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.error, fontSize: 10))
                      else if (task.deadline != null)
                        Text(
                          _dayLabel(task.deadline!),
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PriorityBadge(priority: task.priority.name),
                const SizedBox(height: 4),
                Text(
                  '${task.duration.toStringAsFixed(1)}h',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Delete "${task.title.isNotEmpty ? task.title : 'this task'}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }

  String _dayLabel(DateTime d) {
    final diff = d.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due in ${diff}d';
  }
}

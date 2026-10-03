import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/course_model.dart';
import '../../providers/app_provider.dart';
import 'add_course_screen.dart';
import 'course_details_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _search = '';
  String _filter = 'All';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            _buildSearchBar(context, isDark),
            _buildFilterChips(context),
            _buildTabBar(context, isDark),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildCourseList(context, false),
                  _buildCourseList(context, true),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCourseScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Subject',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.lg, AppSpacing.page, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Subjects', style: AppTextStyles.hero),
              Consumer<AppProvider>(
                builder: (_, p, _) => Text(
                  '${p.activeCourses.length} active · ${p.archivedCourses.length} archived',
                  style: AppTextStyles.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final fill = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Search subjects...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.mutedDark, size: 20),
          filled: true,
          fillColor: fill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: border),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'Urgent', 'High', 'Medium', 'Low']
              .map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      showCheckmark: false,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return TabBar(
      controller: _tab,
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.mutedDark,
      labelStyle:
          AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
      tabs: const [
        Tab(text: 'Active'),
        Tab(text: 'Archived'),
      ],
    );
  }

  Widget _buildCourseList(BuildContext context, bool showArchived) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final all =
            showArchived ? provider.archivedCourses : provider.activeCourses;
        final filtered = all.where((c) {
          if (_search.isNotEmpty &&
              !c.name.toLowerCase().contains(_search.toLowerCase()) &&
              !c.description.toLowerCase().contains(_search.toLowerCase())) {
            return false;
          }
          if (_filter != 'All' &&
              c.priority.toLowerCase() != _filter.toLowerCase()) {
            return false;
          }
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppEmptyState(
              icon: Icons.menu_book_rounded,
              title: showArchived ? 'No archived subjects' : 'No subjects yet',
              message: showArchived
                  ? 'Completed or archived subjects will appear here.'
                  : 'Tap the + button to create your first subject and start building your study plan.',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.md, AppSpacing.page, 100),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _CourseCard(course: filtered[i], provider: provider),
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final AppProvider provider;

  const _CourseCard({required this.course, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final topics = provider.topicsForCourse(course.id);
    final done = topics.where((t) => t.isCompleted).length;
    final progress = topics.isEmpty ? 0.0 : done / topics.length;
    final days = course.daysUntilDeadline;
    final deadlineColor = days < 0
        ? AppColors.error
        : days <= 3
            ? AppColors.accentRose
            : days <= 7
                ? AppColors.accentAmber
                : AppColors.mutedDark;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(courseId: course.id)),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Color avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: course.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: course.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.name,
                          style: AppTextStyles.subtitle,
                          overflow: TextOverflow.ellipsis),
                      if (course.description.isNotEmpty)
                        Text(course.description,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                _popupMenu(context),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            AppProgressBar(value: progress, color: course.color, height: 5),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$done / ${topics.length} topics',
                  style: AppTextStyles.caption,
                ),
                const Spacer(),
                PriorityBadge(priority: course.priority),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 12, color: deadlineColor),
                    const SizedBox(width: 3),
                    Text(
                      days < 0
                          ? 'Overdue'
                          : days == 0
                              ? 'Due today'
                              : '${days}d left',
                      style: AppTextStyles.caption
                          .copyWith(color: deadlineColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _popupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (v) async {
        switch (v) {
          case 'archive':
            await provider.archiveCourse(course.id);
            break;
          case 'unarchive':
            await provider.unarchiveCourse(course.id);
            break;
          case 'delete':
            _confirmDelete(context);
            break;
        }
      },
      itemBuilder: (_) => [
        if (course.isActive)
          const PopupMenuItem(
              value: 'archive',
              child: Text('Archive')),
        if (course.isArchived)
          const PopupMenuItem(
              value: 'unarchive',
              child: Text('Unarchive')),
        const PopupMenuItem(
            value: 'delete',
            child: Text('Delete',
                style: TextStyle(color: AppColors.error))),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: Text(
            'This will delete "${course.name}" and all its topics, tasks, and exams.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteCourse(course.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

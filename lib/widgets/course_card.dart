import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/task_model.dart';
import '../services/course_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'courses/priority_badge.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        CourseService.getTopicsForCourse(course.id),
        CourseService.getAllTasks(),
      ]),
      builder: (context, snapshot) {
        final tasks = snapshot.data?[1] as List<StudyTask>? ?? const [];
        final courseTasks = tasks.where((t) => t.courseId == course.id).toList();
        final completed = courseTasks.where((t) => t.completed).length;
        final progress = courseTasks.isEmpty ? 0.0 : completed / courseTasks.length;
        final percent = (progress * 100).round();

        final firstLetter = course.name.isNotEmpty
            ? course.name.substring(0, 1).toUpperCase()
            : 'C';

<<<<<<< HEAD
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              course.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PriorityBadge(
                            priority: course.priority,
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Due ${shortMonthName(course.deadline.month)} ${course.deadline.day} • $percent%',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3.5,
                          backgroundColor: const Color(0xFF26282E),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  tooltip: 'Course actions',
                  icon: const Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: AppColors.mutedText,
                  ),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete course',
                        style: TextStyle(color: AppColors.error),
                      ),
=======
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Course title + Priority + Menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_stories_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.title.copyWith(fontSize: 16),
                              ),
                              if (course.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  course.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.muted.copyWith(fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PriorityBadge(priority: course.priority, compact: true),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          tooltip: 'Options',
                          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.mutedText),
                          onSelected: (val) {
                            if (val == 'delete') onDelete();
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete course', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Progress bar & percentage
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 7,
                              backgroundColor: AppColors.surfaceSubtle,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$percent%',
                          style: AppTextStyles.bodyBold.copyWith(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Bottom info pills
                    Row(
                      children: [
                        _tag(Icons.layers_outlined, '${topics.length} topics'),
                        const SizedBox(width: 8),
                        _tag(Icons.timer_outlined, '${course.estimatedHours.toStringAsFixed(course.estimatedHours % 1 == 0 ? 0 : 1)}h'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: days < 0
                                ? AppColors.errorLight
                                : (days <= 2 ? AppColors.warningLight : AppColors.surfaceSubtle),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: days < 0
                                    ? AppColors.error
                                    : (days <= 2 ? AppColors.warning : AppColors.mutedText),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                days < 0
                                    ? 'Overdue'
                                    : (days == 0 ? 'Due today' : (days == 1 ? '1 day left' : '$days days left')),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: days < 0
                                      ? AppColors.error
                                      : (days <= 2 ? AppColors.warning : AppColors.mutedText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.mutedText),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.muted.copyWith(fontSize: 12)),
      ],
    );
  }
}
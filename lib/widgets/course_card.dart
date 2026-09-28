import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/task_model.dart';
import '../services/course_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
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
        final topics = snapshot.data?[0] as List? ?? const [];
        final tasks = snapshot.data?[1] as List<StudyTask>? ?? const [];
        final courseTasks = tasks.where((t) => t.courseId == course.id).toList();
        final completed = courseTasks.where((t) => t.completed).length;
        final progress = courseTasks.isEmpty ? 0.0 : completed / courseTasks.length;
        final percent = (progress * 100).round();
        final days = course.deadline.difference(DateTime.now()).inDays;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              course.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.title.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$percent%',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${topics.length} topics · ${course.estimatedHours.toStringAsFixed(course.estimatedHours % 1 == 0 ? 0 : 1)}h',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.muted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PriorityBadge(
                            priority: course.priority,
                            compact: true,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            days < 0 ? 'Overdue' : '$days days',
                            style: AppTextStyles.muted.copyWith(
                              color: days <= 2 ? AppColors.warning : null,
                              fontWeight: days <= 2 ? FontWeight.w600 : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    tooltip: 'Course actions',
                    icon: const Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: AppColors.mutedText,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete course'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
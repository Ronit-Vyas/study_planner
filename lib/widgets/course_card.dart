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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
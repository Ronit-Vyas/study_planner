import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../services/course_service.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';

class TaskRow extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onChanged;

  const TaskRow({
    super.key,
    required this.task,
    required this.onChanged,
  });

  String _hours(double value) {
    if (value == value.roundToDouble()) return '${value.toInt()}h';
    return '${value.toStringAsFixed(1)}h';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        CourseService.getCourseById(task.courseId),
        CourseService.getTopicById(task.topicId),
      ]),
      builder: (context, snapshot) {
        final course = snapshot.data?[0];
        final topic = snapshot.data?[1];
        final topicName = topic?.name ?? 'Study task';
        final courseName = course?.name ?? 'Course';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: task.completed
                ? AppColors.surfaceSubtle.withValues(alpha: 0.6)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.completed ? Colors.transparent : AppColors.cardBorder,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onChanged,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Checkbox indicator
                    GestureDetector(
                      onTap: onChanged,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: task.completed ? AppColors.success : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: task.completed
                                ? AppColors.success
                                : AppColors.mutedText.withValues(alpha: 0.5),
                            width: 1.8,
                          ),
                        ),
                        child: task.completed
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Topic details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topicName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold.copyWith(
                              decoration:
                                  task.completed ? TextDecoration.lineThrough : null,
                              color: task.completed
                                  ? AppColors.mutedText
                                  : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  courseName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Duration badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              size: 12, color: AppColors.mutedText),
                          const SizedBox(width: 4),
                          Text(
                            _hours(task.duration),
                            style: AppTextStyles.muted.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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
}
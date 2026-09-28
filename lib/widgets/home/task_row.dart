import 'package:flutter/material.dart';
import '../../models/task_model.dart';
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

        return InkWell(
          onTap: onChanged,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: Checkbox(
                      value: task.completed,
                      onChanged: (_) => onChanged(),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topicName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.completed
                              ? AppColors.mutedText
                              : AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(courseName, style: AppTextStyles.muted),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _hours(task.duration),
                  style: AppTextStyles.muted.copyWith(
                    fontWeight: FontWeight.w700,
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
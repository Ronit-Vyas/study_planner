import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/course_service.dart';
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
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: task.completed ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: task.completed
                        ? null
                        : Border.all(color: const Color(0xFF4B4F58), width: 1.5),
                  ),
                  child: task.completed
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Color(0xFF081C10),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topicName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.mutedText,
                          color: task.completed
                              ? AppColors.mutedText
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$courseName • ${_hours(task.duration)}',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 13,
                        ),
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
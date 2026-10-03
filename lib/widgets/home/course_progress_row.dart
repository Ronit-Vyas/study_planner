import 'package:flutter/material.dart';
import '../../data/models/course_model.dart';
import '../../data/models/task_model.dart';
import '../../services/course_service.dart';
import '../../utils/constants.dart';
import '../../theme/app_text_styles.dart';

class CourseProgressRow extends StatelessWidget {
  final Course course;
  final List<StudyTask> tasks;

  const CourseProgressRow({super.key, required this.course, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final courseTasks = tasks.where((t) => t.courseId == course.id).toList();
    final completed = courseTasks.where((t) => t.completed).length;
    final progress = courseTasks.isEmpty ? 0.0 : completed / courseTasks.length;
    final percent = (progress * 100).round();

    return FutureBuilder(
      future: CourseService.getTopicsForCourse(course.id),
      builder: (context, snapshot) {
        final topicCount = snapshot.data?.length ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceSubtle,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '$topicCount topics · ${course.estimatedHours.toStringAsFixed(course.estimatedHours % 1 == 0 ? 0 : 1)}h total',
                    style: AppTextStyles.muted.copyWith(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '$completed of ${courseTasks.length} tasks',
                    style: AppTextStyles.muted.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

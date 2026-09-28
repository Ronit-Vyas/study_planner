import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../models/task_model.dart';
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(course.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700))),
                  Text('$percent%', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 5),
              ),
              const SizedBox(height: 5),
              Text('$topicCount topics · ${course.estimatedHours.toStringAsFixed(course.estimatedHours % 1 == 0 ? 0 : 1)}h estimated', style: AppTextStyles.muted),
            ],
          ),
        );
      },
    );
  }
}

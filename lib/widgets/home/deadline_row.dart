import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../utils/helpers.dart';

import '../../screens/courses/course_details_screen.dart';
import '../../utils/constants.dart';
import '../courses/priority_badge.dart';

class DeadlineRow extends StatelessWidget {
  final Course course;

  const DeadlineRow({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(
      course.deadline.year,
      course.deadline.month,
      course.deadline.day,
    );
    final days = deadline.difference(today).inDays;

    final String remainingLabel;
    if (days < 0) {
      remainingLabel = 'Overdue';
    } else if (days == 0) {
      remainingLabel = 'Today';
    } else if (days == 1) {
      remainingLabel = '1 day left';
    } else {
      remainingLabel = '$days days left';
    }

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseDetailsScreen(course: course),
        ),
      ),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${shortMonthName(course.deadline.month)} ${course.deadline.day} · $remainingLabel',
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PriorityBadge(priority: course.priority),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
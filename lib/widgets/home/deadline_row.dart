import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/helpers.dart';

class DeadlineRow extends StatelessWidget {
  final Course course;

  const DeadlineRow({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final deadline = DateTime(
      course.deadline.year,
      course.deadline.month,
      course.deadline.day,
    );

    final days = deadline.difference(today).inDays;

    final bool urgent = days >= 0 && days <= 2;

    final String remainingLabel;

    if (days < 0) {
      remainingLabel = 'Overdue';
    } else if (days == 0) {
      remainingLabel = 'Today';
    } else if (days == 1) {
      remainingLabel = '1d';
    } else {
      remainingLabel = '${days}d';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              course.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 56,
            child: Text(
              formatShortDate(course.deadline),
              textAlign: TextAlign.right,
              style: AppTextStyles.muted,
            ),
          ),

          const SizedBox(width: 16),

          SizedBox(
            width: 48,
            child: Text(
              remainingLabel,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: urgent
                    ? Colors.amber.shade700
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
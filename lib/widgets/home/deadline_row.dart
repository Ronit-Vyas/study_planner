import 'package:flutter/material.dart';
import '../../data/models/course_model.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
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
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(course.deadline.year, course.deadline.month, course.deadline.day);
    final days = deadline.difference(today).inDays;
    final bool urgent = days >= 0 && days <= 2;
    final bool overdue = days < 0;

    final String remainingLabel;
    if (overdue) {
      remainingLabel = 'Overdue';
    } else if (days == 0) {
      remainingLabel = 'Today';
    } else if (days == 1) {
      remainingLabel = 'Tomorrow';
    } else {
      remainingLabel = '$days days left';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: overdue
                  ? AppColors.errorLight
                  : (urgent ? AppColors.warningLight : AppColors.surfaceSubtle),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event_outlined,
              size: 16,
              color: overdue
                  ? AppColors.error
                  : (urgent ? AppColors.warning : AppColors.mutedText),
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
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 2),
                Text(
                  formatShortDate(course.deadline),
                  style: AppTextStyles.muted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: overdue
                  ? AppColors.errorLight
                  : (urgent ? AppColors.warningLight : AppColors.surfaceSubtle),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              remainingLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: overdue
                    ? AppColors.error
                    : (urgent ? AppColors.warning : AppColors.mutedText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
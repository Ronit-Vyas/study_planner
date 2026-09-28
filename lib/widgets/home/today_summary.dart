import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../theme/app_text_styles.dart';

class TodaySummary extends StatelessWidget {
  final int completed;
  final int total;
  final double studiedHours;
  final double remainingHours;

  const TodaySummary({
    super.key,
    required this.completed,
    required this.total,
    required this.studiedHours,
    required this.remainingHours,
  });

  String _hours(double value) => value == value.roundToDouble() ? '${value.toInt()}h' : '${value.toStringAsFixed(1)}h';

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('${(progress * 100).round()}%', style: AppTextStyles.display.copyWith(color: AppColors.primary)),
            ),
            Text('$completed / $total', style: AppTextStyles.title),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(value: progress, minHeight: 7),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('${_hours(studiedHours)} studied', style: AppTextStyles.muted),
            const SizedBox(width: 18),
            Text('${_hours(remainingHours)} left', style: AppTextStyles.muted),
          ],
        ),
      ],
    );
  }
}

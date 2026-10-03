import 'package:flutter/material.dart';
import '../../utils/helpers.dart';

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

<<<<<<< HEAD
  String _hours(double value) => value == value.roundToDouble()
      ? '${value.toInt()}h'
      : '${value.toStringAsFixed(1)}h';
=======
  String _hours(double value) =>
      value == value.roundToDouble() ? '${value.toInt()}h' : '${value.toStringAsFixed(1)}h';
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final progress = total == 0 ? 0.0 : completed / total;
<<<<<<< HEAD
    final totalHours = studiedHours + remainingHours;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF28C76F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today • ${weekdayShort(now.weekday)}, ${shortMonthName(now.month)} ${now.day}',
            style: const TextStyle(
              color: Color(0xFF0F381E),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed/$total tasks done',
            style: const TextStyle(
              color: Color(0xFF052010),
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Color(0xFF0F381E),
              ),
              const SizedBox(width: 5),
              Text(
                '${_hours(totalHours)} planned',
                style: const TextStyle(
                  color: Color(0xFF0F381E),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 18),
              const Icon(
                Icons.track_changes_rounded,
                size: 16,
                color: Color(0xFF0F381E),
              ),
              const SizedBox(width: 5),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF0F381E),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
=======
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('$percent%', style: AppTextStyles.hero.copyWith(color: AppColors.primary)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: progress == 1.0 && total > 0
                                ? AppColors.successLight
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            progress == 1.0 && total > 0 ? '🎉 All done!' : '$completed of $total done',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: progress == 1.0 && total > 0 ? AppColors.success : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      total == 0
                          ? 'No tasks scheduled for today. Great time to relax or plan ahead!'
                          : (progress == 1.0
                              ? 'Fantastic work! You completed your entire study quota.'
                              : 'Keep going! Complete remaining tasks to maintain momentum.'),
                      style: AppTextStyles.muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 && total > 0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _metricTile(Icons.check_circle_outline, 'Finished', '$completed tasks', AppColors.success),
              const SizedBox(width: 10),
              _metricTile(Icons.timer_outlined, 'Studied', _hours(studiedHours), AppColors.primary),
              const SizedBox(width: 10),
              _metricTile(Icons.hourglass_empty, 'Remaining', _hours(remainingHours), AppColors.warning),
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
            ],
          ),
        ],
      ),
<<<<<<< HEAD
=======
    );
  }

  Widget _metricTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedText, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          ],
        ),
      ),
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
    );
  }
}

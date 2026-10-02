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

  String _hours(double value) => value == value.roundToDouble()
      ? '${value.toInt()}h'
      : '${value.toStringAsFixed(1)}h';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final progress = total == 0 ? 0.0 : completed / total;
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
            ],
          ),
        ],
      ),
    );
  }
}

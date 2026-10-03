import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../providers/app_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();

    final totalHours = provider.totalStudyHours;
    final weeklyHours = provider.weeklyStudyHours;
    final weeklyGoal = provider.weeklyHoursGoal;
    final weeklyGoalProgress = (weeklyHours / (weeklyGoal > 0 ? weeklyGoal : 1.0)).clamp(0.0, 1.0);
    final last7Days = provider.last7DaysHours;
    final hoursByCourse = provider.hoursByCourse;
    final completionRate = provider.completionRate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Progress'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            // ── Top Summary Grid ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Studied',
                    value: '${totalHours.toStringAsFixed(1)}h',
                    icon: Icons.timer_rounded,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Day Streak',
                    value: '${provider.currentStreak} 🔥',
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.accentAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Task Completion',
                    value: '${(completionRate * 100).toInt()}%',
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Avg Session',
                    value: '${provider.averageSessionMinutes.round()}m',
                    icon: Icons.timelapse_rounded,
                    iconColor: AppColors.accent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Weekly Goal Progress Card ────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weekly Goal', style: AppTextStyles.subtitle),
                      Text(
                        '${weeklyHours.toStringAsFixed(1)} / ${weeklyGoal.toInt()} hrs',
                        style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppProgressBar(value: weeklyGoalProgress, height: 8),
                  const SizedBox(height: 8),
                  Text(
                    weeklyGoalProgress >= 1.0
                        ? '🎉 Weekly goal achieved! Outstanding work!'
                        : '${((1.0 - weeklyGoalProgress) * weeklyGoal).toStringAsFixed(1)} hours remaining to reach your goal',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Last 7 Days Activity (FL Chart) ──────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Study Activity', style: AppTextStyles.subtitle),
                      Text('Last 7 Days', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _calculateMaxY(last7Days),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.toStringAsFixed(1)} hrs',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (val, meta) => Text(
                                '${val.toInt()}h',
                                style: AppTextStyles.caption.copyWith(fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx < 0 || idx > 6) return const SizedBox();
                                final day = DateTime.now().subtract(Duration(days: 6 - idx));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    DateFormat('E').format(day)[0],
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1.0,
                          getDrawingHorizontalLine: (val) => FlLine(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) {
                          final h = last7Days[i];
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: h,
                                gradient: AppColors.heroGradient,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Subject Breakdown ────────────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject Hours Breakdown', style: AppTextStyles.subtitle),
                  const SizedBox(height: 16),
                  if (hoursByCourse.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No focus sessions recorded yet.\nStart a Focus session to see distribution!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption,
                        ),
                      ),
                    )
                  else
                    ...hoursByCourse.entries.map((entry) {
                      final course = provider.courses.cast<dynamic>().firstWhere(
                            (c) => c.id == entry.key,
                            orElse: () => null,
                          );
                      final cName = course?.name ?? 'Other';
                      final cColor =
                          course != null ? Color(course.colorValue) : AppColors.primary;
                      final fraction =
                          totalHours > 0 ? (entry.value / totalHours).clamp(0.0, 1.0) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: cColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(cName, style: AppTextStyles.bodyBold),
                                const Spacer(),
                                Text(
                                  '${entry.value.toStringAsFixed(1)}h (${(fraction * 100).toInt()}%)',
                                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            AppProgressBar(value: fraction, color: cColor, height: 6),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Recent Sessions ──────────────────────────────────────────────
            AppSection(
              title: 'Recent Study Sessions',
              child: provider.sessions.isEmpty
                  ? AppEmptyState(
                      icon: Icons.history_edu_rounded,
                      title: 'No Session Records',
                      message: 'Sessions recorded with the Pomodoro timer will appear here.',
                    )
                  : Column(
                      children: provider.sessions.reversed.take(5).map((s) {
                        final course = provider.courses.cast<dynamic>().firstWhere(
                              (c) => c.id == s.courseId,
                              orElse: () => null,
                            );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.timer_rounded,
                                      color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course?.name ?? 'Study Session',
                                        style: AppTextStyles.bodyBold,
                                      ),
                                      Text(
                                        DateFormat('MMM d · h:mm a').format(s.startTime),
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${s.durationMinutes} min',
                                      style: AppTextStyles.bodyBold.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        s.productivityRating,
                                        (_) => const Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: AppColors.accentAmber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(List<double> values) {
    double max = 3.0;
    for (final v in values) {
      if (v > max) max = v;
    }
    return (max * 1.2).ceilToDouble();
  }
}

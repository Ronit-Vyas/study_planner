import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/exam_model.dart';
import '../../providers/app_provider.dart';
import 'add_exam_screen.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final allExams = provider.exams;

    final upcomingExams = allExams.where((e) => !e.isPast).toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));

    final pastExams = allExams.where((e) => e.isPast).toList()
      ..sort((a, b) => b.examDate.compareTo(a.examDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams & Tests'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExamScreen()),
        ),
        backgroundColor: AppColors.accentRose,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Exam', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: allExams.isEmpty
          ? AppEmptyState(
              icon: Icons.event_note_rounded,
              title: 'No Exams Scheduled',
              message:
                  'Keep track of midterms, finals, quizzes, and deadlines with automatic countdown timers.',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExamScreen()),
                ),
                label: const Text('Schedule an Exam'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                80,
              ),
              children: [
                if (upcomingExams.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.alarm_rounded, color: AppColors.accentRose, size: 20),
                      const SizedBox(width: 8),
                      Text('Upcoming Exams (${upcomingExams.length})', style: AppTextStyles.subtitle),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...upcomingExams.map((e) => _ExamCard(exam: e, isDark: isDark)),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (pastExams.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, color: AppColors.mutedDark, size: 20),
                      const SizedBox(width: 8),
                      Text('Past Exams (${pastExams.length})', style: AppTextStyles.subtitle),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...pastExams.map((e) => _ExamCard(exam: e, isDark: isDark, isPast: true)),
                ],
              ],
            ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final bool isDark;
  final bool isPast;

  const _ExamCard({
    required this.exam,
    required this.isDark,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final course = provider.courses.cast<dynamic>().firstWhere(
          (c) => c.id == exam.courseId,
          orElse: () => null,
        );

    final days = exam.daysUntilExam;
    String countdownText;
    Color countdownColor;

    if (isPast) {
      countdownText = 'Ended';
      countdownColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    } else if (days == 0) {
      countdownText = 'TODAY!';
      countdownColor = AppColors.urgent;
    } else if (days == 1) {
      countdownText = 'Tomorrow!';
      countdownColor = AppColors.high;
    } else {
      countdownText = 'in $days days';
      countdownColor = days <= 7 ? AppColors.accentAmber : AppColors.primary;
    }

    final courseColor = course != null ? Color(course.colorValue) : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => _showExamDetails(context, exam, course?.name ?? 'Subject'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: courseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  course?.name ?? 'Subject',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: countdownColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    countdownText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: countdownColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(exam.name, style: AppTextStyles.title),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 15, color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
                const SizedBox(width: 4),
                Text(
                  DateFormat('EEEE, MMM d · h:mm a').format(exam.examDate),
                  style: AppTextStyles.caption,
                ),
                if (exam.targetScore > 0) ...[
                  const Spacer(),
                  Icon(Icons.military_tech_rounded, size: 16, color: AppColors.accentAmber),
                  const SizedBox(width: 4),
                  Text('Target: ${exam.targetScore.toInt()}%', style: AppTextStyles.caption),
                ],
              ],
            ),
            if (exam.syllabus.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                exam.syllabus,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExamDetails(BuildContext context, Exam exam, String courseName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(exam.name, style: AppTextStyles.hero)),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExamScreen(existingExam: exam),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await context.read<AppProvider>().deleteExam(exam.id);
                  },
                ),
              ],
            ),
            Text(courseName, style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date & Time',
              value: DateFormat('EEEE, MMMM d, yyyy · h:mm a').format(exam.examDate),
            ),
            if (exam.targetScore > 0)
              _DetailRow(
                icon: Icons.military_tech_rounded,
                label: 'Target Score',
                value: '${exam.targetScore.toInt()}%',
              ),
            if (exam.syllabus.isNotEmpty)
              _DetailRow(
                icon: Icons.menu_book_rounded,
                label: 'Syllabus',
                value: exam.syllabus,
              ),
            if (exam.notes.isNotEmpty)
              _DetailRow(
                icon: Icons.notes_rounded,
                label: 'Notes & Instructions',
                value: exam.notes,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

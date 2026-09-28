import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/course_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_section.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/home/task_row.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<StudyTask> dayTasks = [];
  bool isLoading = true;
  Map<String, List<StudyTask>> monthTasks = {};

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<void> _loadMonth() async {
    if (mounted) setState(() => isLoading = true);

    final first = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final last = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);
    final tasks = await CourseService.getAllTasks();
    final map = <String, List<StudyTask>>{};

    for (final task in tasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);
      if (!date.isBefore(first) && !date.isAfter(last)) {
        map.putIfAbsent(_key(date), () => []).add(task);
      }
    }

    if (!mounted) return;

    setState(() {
      monthTasks = map;
      dayTasks = map[_key(selectedDate)] ?? [];
      isLoading = false;
    });
  }

  void _select(DateTime date) {
    setState(() {
      selectedDate = date;
      dayTasks = monthTasks[_key(date)] ?? [];
    });
  }

  void _changeMonth(int delta) {
    final next = DateTime(visibleMonth.year, visibleMonth.month + delta);
    setState(() {
      visibleMonth = next;
      selectedDate = DateTime(next.year, next.month, 1);
    });
    _loadMonth();
  }

  Future<void> _toggleTask(StudyTask task) async {
    await CourseService.toggleTaskCompleted(task.id);
    await _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    final completed = dayTasks.where((t) => t.completed).length;
    final totalHours = dayTasks.fold<double>(0, (sum, task) => sum + task.duration);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 900 ? 760.0 : double.infinity;

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  22,
                  AppSpacing.page,
                  36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calendar', style: AppTextStyles.display),
                    const SizedBox(height: 4),
                    const Text(
                      'Your study schedule by day',
                      style: AppTextStyles.muted,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    _calendarHeader(),
                    const SizedBox(height: 10),
                    _calendarGrid(),
                    const SizedBox(height: AppSpacing.section),
                    AppSection(
                      title: formatLongDate(selectedDate),
                      trailing: Text(
                        '${dayTasks.length} ${dayTasks.length == 1 ? 'task' : 'tasks'} · ${_hours(totalHours)}',
                        style: AppTextStyles.muted,
                      ),
                      child: isLoading
                          ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                          : dayTasks.isEmpty
                          ? const EmptyState(
                        icon: Icons.event_available_outlined,
                        title: 'No study tasks',
                        message: 'There are no scheduled tasks for this day.',
                      )
                          : Column(
                        children: dayTasks
                            .map(
                              (task) => TaskRow(
                            task: task,
                            onChanged: () => _toggleTask(task),
                          ),
                        )
                            .toList(),
                      ),
                      dividerAfter: false,
                    ),
                    if (dayTasks.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '$completed of ${dayTasks.length} completed',
                        style: AppTextStyles.muted,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _calendarHeader() {
    return Row(
      children: [
        _monthButton(
          icon: Icons.chevron_left,
          tooltip: 'Previous month',
          onPressed: () => _changeMonth(-1),
        ),
        Expanded(
          child: Text(
            '${monthName(visibleMonth.month)} ${visibleMonth.year}',
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),
        ),
        _monthButton(
          icon: Icons.chevron_right,
          tooltip: 'Next month',
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _monthButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 22),
      ),
    );
  }

  Widget _calendarGrid() {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final offset = firstDay.weekday - DateTime.monday;
    final cells = offset + daysInMonth;
    final rows = (cells / 7).ceil();
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayKey = _key(DateTime.now());

    return Column(
      children: [
        Row(
          children: weekdays
              .map(
                (day) => Expanded(
              child: Center(child: Text(day, style: AppTextStyles.label)),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: 6),
        for (int row = 0; row < rows; row++)
          Row(
            children: List.generate(7, (column) {
              final index = row * 7 + column;
              final day = index - offset + 1;

              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }

              final date = DateTime(visibleMonth.year, visibleMonth.month, day);
              final tasks = monthTasks[_key(date)] ?? [];
              final allDone = tasks.isNotEmpty && tasks.every((t) => t.completed);
              final isSelected = _key(date) == _key(selectedDate);
              final isToday = _key(date) == todayKey;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Material(
                    color: isSelected ? AppColors.primaryLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => _select(date),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (tasks.isNotEmpty)
                              Icon(
                                allDone ? Icons.check : Icons.circle,
                                size: 9,
                                color: allDone
                                    ? AppColors.success
                                    : AppColors.primary,
                              )
                            else if (isToday)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(height: 9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        const SizedBox(height: 12),
        const Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 14,
          runSpacing: 6,
          children: [
            _CalendarLegend(icon: Icons.check, color: AppColors.success, label: 'Completed'),
            _CalendarLegend(icon: Icons.circle, color: AppColors.primary, label: 'Scheduled'),
          ],
        ),
      ],
    );
  }

  String _hours(double value) => value == value.roundToDouble()
      ? '${value.toInt()}h'
      : '${value.toStringAsFixed(1)}h';
}

class _CalendarLegend extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _CalendarLegend({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.muted),
      ],
    );
  }
}

String formatLongDate(DateTime date) => '${monthName(date.month)} ${date.day}';
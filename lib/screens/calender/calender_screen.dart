import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 900 ? 760.0 : double.infinity;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    20,
                    AppSpacing.page,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Study Calendar', style: AppTextStyles.hero),
                      const SizedBox(height: 2),
                      const Text(
                        'Track your scheduled study sessions and daily progress',
                        style: AppTextStyles.muted,
                      ),
                      const SizedBox(height: 20),

                      // Calendar Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                            _calendarHeader(),
                            const SizedBox(height: 14),
                            _calendarGrid(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Day's Tasks Section
                      AppSection(
                        title: formatLongDate(selectedDate),
                        trailing: dayTasks.isNotEmpty
                            ? Text(
                                '${dayTasks.length} ${dayTasks.length == 1 ? 'task' : 'tasks'} · ${_hours(totalHours)}',
                                style: AppTextStyles.muted,
                              )
                            : null,
                        dividerAfter: false,
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : dayTasks.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: const EmptyState(
                                      icon: Icons.event_available_outlined,
                                      title: 'No study tasks for this day',
                                      message: 'Pick another day with scheduled dots or generate a schedule from Courses.',
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...dayTasks.map(
                                        (task) => TaskRow(
                                          task: task,
                                          onChanged: () => _toggleTask(task),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            completed == dayTasks.length ? Icons.check_circle : Icons.info_outline,
                                            size: 15,
                                            color: completed == dayTasks.length ? AppColors.success : AppColors.mutedText,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$completed of ${dayTasks.length} tasks completed',
                                            style: AppTextStyles.muted.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _calendarHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left, color: AppColors.text),
        ),
        Expanded(
          child: Text(
            '${monthName(visibleMonth.month)} ${visibleMonth.year}',
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          tooltip: 'Next month',
          icon: const Icon(Icons.chevron_right, color: AppColors.text),
        ),
      ],
    );
  }

  Widget _calendarGrid() {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final offset = firstDay.weekday - DateTime.monday;
    final cells = offset + daysInMonth;
    final rows = (cells / 7).ceil();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayKey = _key(DateTime.now());

    return Column(
      children: [
        Row(
          children: weekdays
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        for (int row = 0; row < rows; row++) ...[
          Row(
            children: List.generate(7, (column) {
              final index = row * 7 + column;
              final day = index - offset + 1;

              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox(height: 46));
              }

              final date = DateTime(visibleMonth.year, visibleMonth.month, day);
              final tasks = monthTasks[_key(date)] ?? [];
              final allDone = tasks.isNotEmpty && tasks.every((t) => t.completed);
              final isSelected = _key(date) == _key(selectedDate);
              final isToday = _key(date) == todayKey;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: InkWell(
                    onTap: () => _select(date),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isToday ? AppColors.primaryLight : Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isToday && !isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isToday ? AppColors.primary : AppColors.text),
                            ),
                          ),
                          const SizedBox(height: 3),
                          if (tasks.isNotEmpty)
                            Icon(
                              allDone ? Icons.check_circle : Icons.circle,
                              size: 8,
                              color: isSelected
                                  ? Colors.white
                                  : (allDone ? AppColors.success : AppColors.primary),
                            )
                          else
                            const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (row < rows - 1) const SizedBox(height: 4),
        ],
        const SizedBox(height: 14),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            _CalendarLegend(icon: Icons.check_circle, color: AppColors.success, label: 'Completed'),
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
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
      ],
    );
  }
}

String formatLongDate(DateTime date) {
  const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models/study_session_model.dart';
import '../../providers/app_provider.dart';

enum TimerMode { focus, shortBreak, longBreak }

class FocusScreen extends StatefulWidget {
  final String? initialCourseId;

  const FocusScreen({super.key, this.initialCourseId});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  TimerMode _mode = TimerMode.focus;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _sessionStartTime;

  String? _selectedCourseId;
  String? _selectedTopicId;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.initialCourseId;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialise with provider preference if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final p = context.read<AppProvider>();
        if (_selectedCourseId == null && p.activeCourses.isNotEmpty) {
          setState(() {
            _selectedCourseId = p.activeCourses.first.id;
            _totalSeconds = p.focusDuration * 60;
            _remainingSeconds = _totalSeconds;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _switchMode(TimerMode mode) {
    _timer?.cancel();
    final p = context.read<AppProvider>();
    int duration;
    switch (mode) {
      case TimerMode.focus:
        duration = p.focusDuration * 60;
        break;
      case TimerMode.shortBreak:
        duration = p.breakDuration * 60;
        break;
      case TimerMode.longBreak:
        duration = 15 * 60;
        break;
    }

    setState(() {
      _mode = mode;
      _isRunning = false;
      _totalSeconds = duration;
      _remainingSeconds = duration;
      _sessionStartTime = null;
    });
  }

  void _setCustomMinutes(int minutes) {
    if (_isRunning) return;
    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _startTimer() {
    if (_isRunning) return;
    _sessionStartTime ??= DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _handleCompletedSession();
      }
    });

    setState(() => _isRunning = true);
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
      _sessionStartTime = null;
    });
  }

  Future<void> _handleCompletedSession() async {
    if (_mode == TimerMode.focus && _selectedCourseId != null) {
      final provider = context.read<AppProvider>();
      final now = DateTime.now();
      final start = _sessionStartTime ?? now.subtract(Duration(seconds: _totalSeconds));

      int rating = 4;
      final notesCtrl = TextEditingController();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
          builder: (dialogCtx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.stars_rounded, color: AppColors.accentAmber, size: 28),
                SizedBox(width: 8),
                Text('Session Complete! 🎉'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Great job! You stayed focused for ${(_totalSeconds / 60).round()} minutes.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  Text('How productive was this session?', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.accentAmber,
                          size: 32,
                        ),
                        onPressed: () => setDialogState(() => rating = star),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      hintText: 'Add notes about what you covered...',
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Skip Recording'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final session = StudySession(
                    id: provider.newId(),
                    courseId: _selectedCourseId!,
                    topicId: _selectedTopicId ?? '',
                    startTime: start,
                    endTime: now,
                    productivityRating: rating,
                    notes: notesCtrl.text.trim(),
                    wasPomodoro: true,
                  );
                  await provider.addSession(session);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Session'),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Break finished! Ready to focus again?'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
    _resetTimer();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final courses = provider.activeCourses;
    final progress = _totalSeconds > 0 ? (_remainingSeconds / _totalSeconds) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus & Pomodoro'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Timer settings',
            onPressed: () => _showSettingsModal(context, provider),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),

              // Mode Tabs (Focus / Short Break / Long Break)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _ModeTab(
                      label: 'Focus',
                      icon: Icons.local_fire_department_rounded,
                      activeColor: AppColors.primary,
                      isSelected: _mode == TimerMode.focus,
                      onTap: () => _switchMode(TimerMode.focus),
                    ),
                    _ModeTab(
                      label: 'Short Break',
                      icon: Icons.coffee_rounded,
                      activeColor: AppColors.accentGreen,
                      isSelected: _mode == TimerMode.shortBreak,
                      onTap: () => _switchMode(TimerMode.shortBreak),
                    ),
                    _ModeTab(
                      label: 'Long Break',
                      icon: Icons.spa_rounded,
                      activeColor: AppColors.accent,
                      isSelected: _mode == TimerMode.longBreak,
                      onTap: () => _switchMode(TimerMode.longBreak),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Course Selector Chip
              if (_mode == TimerMode.focus) ...[
                if (courses.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCourseId ?? courses.first.id,
                        isDense: true,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        items: courses.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Color(c.colorValue),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  c.name,
                                  style: AppTextStyles.bodyBold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _isRunning
                            ? null
                            : (id) => setState(() => _selectedCourseId = id),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Add a subject from the Subjects tab to record focus hours',
                    style: AppTextStyles.caption,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
              ],

              // Duration preset chips
              if (!_isRunning && _mode == TimerMode.focus) ...[
                Wrap(
                  spacing: 8,
                  children: [15, 25, 45, 60].map((mins) {
                    final isCur = (_totalSeconds ~/ 60) == mins;
                    return ChoiceChip(
                      label: Text('${mins}m'),
                      selected: isCur,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontWeight: isCur ? FontWeight.bold : FontWeight.normal,
                        color: isCur ? AppColors.primary : null,
                      ),
                      onSelected: (_) => _setCustomMinutes(mins),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Main Circular Timer
              Center(
                child: ScaleTransition(
                  scale: _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Track & Gradient Progress Ring
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 14,
                          backgroundColor: isDark
                              ? AppColors.surfaceDark2
                              : AppColors.surfaceLight2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _mode == TimerMode.focus
                                ? AppColors.primary
                                : (_mode == TimerMode.shortBreak
                                    ? AppColors.accentGreen
                                    : AppColors.accent),
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Timer Content Inside Circle
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _mode == TimerMode.focus
                                ? Icons.timer_rounded
                                : (_mode == TimerMode.shortBreak
                                    ? Icons.coffee_rounded
                                    : Icons.spa_rounded),
                            size: 28,
                            color: _mode == TimerMode.focus
                                ? AppColors.primary
                                : (_mode == TimerMode.shortBreak
                                    ? AppColors.accentGreen
                                    : AppColors.accent),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: AppTextStyles.hero.copyWith(
                              fontSize: 48,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRunning
                                ? 'STAY DEEP IN FOCUS'
                                : (_remainingSeconds == _totalSeconds
                                    ? 'READY TO START'
                                    : 'PAUSED'),
                            style: AppTextStyles.caption.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Controls (Play / Pause / Reset)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    iconSize: 26,
                    padding: const EdgeInsets.all(16),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Reset timer',
                    onPressed: _resetTimer,
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: _mode == TimerMode.focus
                            ? AppColors.heroGradient
                            : (_mode == TimerMode.shortBreak
                                ? AppColors.successGradient
                                : AppColors.accentGradient),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_mode == TimerMode.focus
                                    ? AppColors.primary
                                    : AppColors.accentGreen)
                                .withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton.filledTonal(
                    iconSize: 26,
                    padding: const EdgeInsets.all(16),
                    icon: const Icon(Icons.skip_next_rounded),
                    tooltip: 'Skip',
                    onPressed: () {
                      _timer?.cancel();
                      _handleCompletedSession();
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Focus Stats Summary Card
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MiniStat(
                      label: "Today's Focus",
                      value: '${(provider.todayStudyHours * 60).round()}m',
                      icon: Icons.timelapse_rounded,
                      color: AppColors.primary,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    _MiniStat(
                      label: 'Day Streak',
                      value: '${provider.currentStreak} 🔥',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.accentAmber,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    _MiniStat(
                      label: 'Sessions',
                      value: '${provider.sessions.where((s) {
                        final now = DateTime.now();
                        return s.startTime.year == now.year &&
                            s.startTime.month == now.month &&
                            s.startTime.day == now.day;
                      }).length}',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.accentGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsModal(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timer Customization', style: AppTextStyles.title),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Focus Duration'),
              subtitle: Text('${provider.focusDuration} minutes'),
              trailing: DropdownButton<int>(
                value: provider.focusDuration,
                items: [15, 20, 25, 30, 45, 50, 60]
                    .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    provider.setFocusDuration(val);
                    if (_mode == TimerMode.focus && !_isRunning) {
                      _switchMode(TimerMode.focus);
                    }
                    Navigator.pop(ctx);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Break Duration'),
              subtitle: Text('${provider.breakDuration} minutes'),
              trailing: DropdownButton<int>(
                value: provider.breakDuration,
                items: [3, 5, 10, 15]
                    .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    provider.setBreakDuration(val);
                    if (_mode == TimerMode.shortBreak && !_isRunning) {
                      _switchMode(TimerMode.shortBreak);
                    }
                    Navigator.pop(ctx);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color activeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? activeColor : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(value, style: AppTextStyles.bodyBold),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

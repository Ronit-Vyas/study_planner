import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/task_model.dart';
import '../../data/models/topic_model.dart';
import '../../providers/app_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final String? initialCourseId;
  final String? initialTopicId;
  final DateTime? initialDate;

  const AddTaskScreen({
    super.key,
    this.initialCourseId,
    this.initialTopicId,
    this.initialDate,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCourseId;
  String? _selectedTopicId;
  late DateTime _scheduledDate;
  DateTime? _deadline;
  TaskPriority _priority = TaskPriority.medium;
  double _duration = 1.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.initialCourseId;
    _selectedTopicId = widget.initialTopicId;
    _scheduledDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduledDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null || _selectedCourseId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject for this task'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<AppProvider>();

    final task = StudyTask(
      id: provider.newId(),
      courseId: _selectedCourseId!,
      topicId: _selectedTopicId ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      scheduledDate: _scheduledDate,
      duration: _duration,
      status: TaskStatus.todo,
      priority: _priority,
      deadline: _deadline,
      notes: _notesController.text.trim(),
    );

    await provider.addTask(task);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.title}" scheduled!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final courses = provider.activeCourses;

    if (_selectedCourseId == null && courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
    }

    final availableTopics = _selectedCourseId != null
        ? provider.topicsForCourse(_selectedCourseId!)
        : <Topic>[];

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Study Task'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.title,
                decoration: InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'e.g., Read Chapter 4 & Practice Problems',
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Subject Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCourseId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Subject *',
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                items: courses.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(c.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCourseId = val;
                    _selectedTopicId = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Topic Dropdown (if topics available)
              if (availableTopics.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _selectedTopicId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Linked Topic (Optional)',
                    prefixIcon: const Icon(Icons.bookmark_outline_rounded),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No specific topic'),
                    ),
                    ...availableTopics.map(
                      (t) => DropdownMenuItem<String?>(
                        value: t.id,
                        child: Text(t.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedTopicId = val),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Scheduled Date & Deadline Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickScheduledDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('Scheduled Date', style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('EEE, MMM d').format(_scheduledDate),
                              style: AppTextStyles.bodyBold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDeadline,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flag_outlined,
                                    size: 16, color: AppColors.accentRose),
                                const SizedBox(width: 6),
                                Text('Deadline (Optional)', style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _deadline != null
                                  ? DateFormat('EEE, MMM d').format(_deadline!)
                                  : 'None set',
                              style: AppTextStyles.bodyBold.copyWith(
                                color: _deadline != null
                                    ? null
                                    : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Priority Selector
              Text('Priority', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final isSelected = _priority == p;
                  final color = switch (p) {
                    TaskPriority.low => AppColors.low,
                    TaskPriority.medium => AppColors.medium,
                    TaskPriority.high => AppColors.high,
                    TaskPriority.urgent => AppColors.urgent,
                  };

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.18)
                              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            p.name[0].toUpperCase() + p.name.substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? color : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Duration Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estimated Duration', style: AppTextStyles.label),
                  Text(
                    '${_duration.toStringAsFixed(1)} hours (${(_duration * 60).toInt()} min)',
                    style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              Slider(
                value: _duration,
                min: 0.25,
                max: 6.0,
                divisions: 23,
                activeColor: AppColors.primary,
                label: '${_duration.toStringAsFixed(1)}h',
                onChanged: (v) => setState(() => _duration = v),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Description / Notes
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Task Details (Optional)',
                  hintText: 'What specifically do you need to complete?',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Personal Notes & Checklist (Optional)',
                  hintText: 'Formula cheat-sheets, links, page ranges...',
                  prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Task',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

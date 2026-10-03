import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/course_model.dart';
import '../../providers/app_provider.dart';

class AddCourseScreen extends StatefulWidget {
  final Course? existing;
  const AddCourseScreen({super.key, this.existing});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '20');

  String _priority = 'medium';
  CourseDifficulty _difficulty = CourseDifficulty.medium;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  int _colorIndex = 0;
  bool _isSaving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = widget.existing!;
      _nameCtrl.text = c.name;
      _descCtrl.text = c.description;
      _hoursCtrl.text = c.estimatedHours.toStringAsFixed(0);
      _priority = c.priority;
      _difficulty = c.difficulty;
      _deadline = c.deadline;
      _colorIndex = c.colorIndex;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Subject' : 'New Subject'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color picker
              Text('Subject Color', style: AppTextStyles.subtitle),
              const SizedBox(height: 12),
              _colorPicker(),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subject Name *',
                  hintText: 'e.g. Mathematics, Operating Systems',
                  prefixIcon: Icon(Icons.menu_book_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of this subject...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Estimated hours
              TextFormField(
                controller: _hoursCtrl,
                decoration: const InputDecoration(
                  labelText: 'Estimated Study Hours *',
                  hintText: 'e.g. 40',
                  prefixIcon: Icon(Icons.schedule_rounded),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final h = double.tryParse(v ?? '');
                  if (h == null || h <= 0) {
                    return 'Enter a valid number of hours (> 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Deadline
              Text('Deadline', style: AppTextStyles.subtitle),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark2
                        : AppColors.surfaceLight2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(_formatDate(_deadline),
                          style: AppTextStyles.body),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.mutedDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Priority
              Text('Priority', style: AppTextStyles.subtitle),
              const SizedBox(height: 10),
              _prioritySelector(),
              const SizedBox(height: 24),

              // Difficulty
              Text('Difficulty', style: AppTextStyles.subtitle),
              const SizedBox(height: 10),
              _difficultySelector(),
              const SizedBox(height: 40),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isEdit ? 'Update Subject' : 'Create Subject'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(AppColors.subjectPalette.length, (i) {
        final color = AppColors.subjectPalette[i];
        final selected = _colorIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _colorIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(color: Colors.white, width: 2.5)
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2)
                    ]
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18)
                : null,
          ),
        );
      }),
    );
  }

  Widget _prioritySelector() {
    final options = ['low', 'medium', 'high', 'urgent'];
    final colors = [
      AppColors.low,
      AppColors.medium,
      AppColors.high,
      AppColors.urgent,
    ];

    return Row(
      children: List.generate(options.length, (i) {
        final selected = _priority == options[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _priority = options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? colors[i].withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? colors[i] : AppColors.borderDark,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  options[i].substring(0, 1).toUpperCase() +
                      options[i].substring(1),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: selected ? colors[i] : AppColors.mutedDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _difficultySelector() {
    final options = [
      ('Easy', CourseDifficulty.easy),
      ('Medium', CourseDifficulty.medium),
      ('Hard', CourseDifficulty.hard),
    ];
    final colors = [
      AppColors.accentGreen,
      AppColors.accentAmber,
      AppColors.accentRose,
    ];

    return Row(
      children: List.generate(options.length, (i) {
        final (label, diff) = options[i];
        final selected = _difficulty == diff;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _difficulty = diff),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? colors[i].withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? colors[i] : AppColors.borderDark,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: selected ? colors[i] : AppColors.mutedDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<AppProvider>();
    final hours = double.parse(_hoursCtrl.text);

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        estimatedHours: hours,
        priority: _priority,
        difficulty: _difficulty,
        deadline: _deadline,
        colorIndex: _colorIndex,
      );
      await provider.updateCourse(updated);
    } else {
      final course = Course(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        estimatedHours: hours,
        priority: _priority,
        difficulty: _difficulty,
        deadline: _deadline,
        colorIndex: _colorIndex,
      );
      await provider.addCourse(course);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, true);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

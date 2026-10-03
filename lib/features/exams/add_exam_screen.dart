import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/exam_model.dart';
import '../../providers/app_provider.dart';

class AddExamScreen extends StatefulWidget {
  final String? initialCourseId;
  final Exam? existingExam;

  const AddExamScreen({
    super.key,
    this.initialCourseId,
    this.existingExam,
  });

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _syllabusController = TextEditingController();
  final _notesController = TextEditingController();
  final _targetScoreController = TextEditingController(text: '90');

  String? _selectedCourseId;
  late DateTime _examDate;
  TimeOfDay _examTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingExam != null) {
      final e = widget.existingExam!;
      _nameController.text = e.name;
      _syllabusController.text = e.syllabus;
      _notesController.text = e.notes;
      _targetScoreController.text = e.targetScore.toInt().toString();
      _selectedCourseId = e.courseId;
      _examDate = e.examDate;
      _examTime = TimeOfDay(hour: e.examDate.hour, minute: e.examDate.minute);
    } else {
      _selectedCourseId = widget.initialCourseId;
      _examDate = DateTime.now().add(const Duration(days: 14));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _syllabusController.dispose();
    _notesController.dispose();
    _targetScoreController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _examDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _examTime,
    );
    if (picked != null) {
      setState(() => _examTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null || _selectedCourseId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject for this exam'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<AppProvider>();

    final finalDateTime = DateTime(
      _examDate.year,
      _examDate.month,
      _examDate.day,
      _examTime.hour,
      _examTime.minute,
    );

    final targetScore = double.tryParse(_targetScoreController.text.trim()) ?? 85.0;

    if (widget.existingExam != null) {
      final updated = widget.existingExam!.copyWith(
        name: _nameController.text.trim(),
        courseId: _selectedCourseId!,
        examDate: finalDateTime,
        syllabus: _syllabusController.text.trim(),
        targetScore: targetScore,
        notes: _notesController.text.trim(),
      );
      await provider.updateExam(updated);
    } else {
      final exam = Exam(
        id: provider.newId(),
        courseId: _selectedCourseId!,
        name: _nameController.text.trim(),
        examDate: finalDateTime,
        syllabus: _syllabusController.text.trim(),
        targetScore: targetScore,
        notes: _notesController.text.trim(),
      );
      await provider.addExam(exam);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exam "${_nameController.text.trim()}" saved!'),
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

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingExam != null ? 'Edit Exam' : 'Schedule Exam'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.title,
                decoration: InputDecoration(
                  labelText: 'Exam Title *',
                  hintText: 'e.g., Midterm Exam / Final Test',
                  prefixIcon: const Icon(Icons.assignment_turned_in_rounded),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter exam title' : null,
              ),
              const SizedBox(height: AppSpacing.md),

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
                        Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCourseId = val),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
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
                                const Icon(Icons.event_rounded, size: 16, color: AppColors.accentRose),
                                const SizedBox(width: 6),
                                Text('Exam Date', style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('EEE, MMM d, yyyy').format(_examDate),
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
                      onTap: _pickTime,
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
                                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('Time', style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _examTime.format(context),
                              style: AppTextStyles.bodyBold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _targetScoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Score (%)',
                  hintText: 'e.g., 90',
                  prefixIcon: const Icon(Icons.military_tech_outlined),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _syllabusController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Syllabus & Topics Covered',
                  hintText: 'Units 1-4: Quantum Mechanics, Wave Equations...',
                  prefixIcon: const Icon(Icons.menu_book_outlined),
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
                  labelText: 'Important Instructions / Room No.',
                  hintText: 'Bring scientific calculator, Room 402, Hall B',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.existingExam != null ? 'Update Exam' : 'Schedule Exam',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

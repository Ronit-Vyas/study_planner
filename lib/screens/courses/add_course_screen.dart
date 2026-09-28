import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});
  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final hoursController = TextEditingController();
  DateTime? selectedDeadline;
  String selectedPriority = 'Medium';
  bool saving = false;

  @override
  void dispose() { nameController.dispose(); descriptionController.dispose(); hoursController.dispose(); super.dispose(); }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now.add(const Duration(days: 7)), firstDate: now, lastDate: now.add(const Duration(days: 3650)));
    if (picked != null) setState(() => selectedDeadline = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDeadline == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a deadline first.'))); return; }
    setState(() => saving = true);
    await CourseService.addCourse(Course(id: DateTime.now().millisecondsSinceEpoch.toString(), name: nameController.text.trim(), description: descriptionController.text.trim(), deadline: selectedDeadline!, priority: selectedPriority, estimatedHours: double.parse(hoursController.text.trim())));
    if (!mounted) return;
    setState(() => saving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)), title: const Text('Create Course')), body: SingleChildScrollView(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.page, 10, AppSpacing.page, 36), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Create Course', style: AppTextStyles.display), const SizedBox(height: 5), const Text('Add the information needed to build your study plan.', style: AppTextStyles.muted), const SizedBox(height: AppSpacing.section),
      _label('Course'), TextFormField(controller: nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Data Structures'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a course name' : null),
      const SizedBox(height: AppSpacing.lg), _label('Description'), TextFormField(controller: descriptionController, maxLines: 3, decoration: const InputDecoration(hintText: 'Optional description')),
      const SizedBox(height: AppSpacing.lg), _label('Estimated study time'), TextFormField(controller: hoursController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: '10', suffixText: 'hours'), validator: (v) { final value = double.tryParse(v?.trim() ?? ''); return value == null || value <= 0 ? 'Enter a valid number' : null; }),
      const SizedBox(height: AppSpacing.lg), _label('Deadline'), InkWell(onTap: _pickDeadline, borderRadius: BorderRadius.circular(10), child: InputDecorator(decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today_outlined)), child: Text(selectedDeadline == null ? 'Select deadline' : '${selectedDeadline!.day.toString().padLeft(2, '0')} ${_month(selectedDeadline!.month)} ${selectedDeadline!.year}', style: selectedDeadline == null ? AppTextStyles.muted : AppTextStyles.body))),
      const SizedBox(height: AppSpacing.lg), _label('Priority'), Row(children: ['Low', 'Medium', 'High'].map((priority) { final selected = selectedPriority == priority; return Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(selected: selected, label: Center(child: Text(priority)), onSelected: (_) => setState(() => selectedPriority = priority), selectedColor: AppColors.primaryLight, labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.text, fontWeight: FontWeight.w700, fontSize: 12), side: BorderSide(color: selected ? AppColors.primary : AppColors.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), showCheckmark: false))); }).toList()),
      const SizedBox(height: AppSpacing.xxl), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: saving ? null : _save, child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Course'))),
    ])))))));
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(text.toUpperCase(), style: AppTextStyles.label));
  String _month(int m) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
}

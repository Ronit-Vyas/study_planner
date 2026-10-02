import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../models/topic_model.dart';
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

  // Topic inline form controllers
  final _topicNameController = TextEditingController();
  final _topicHoursController = TextEditingController();

  DateTime? selectedDeadline;
  String selectedPriority = 'Medium';
  bool saving = false;

  /// Topics staged for creation (persisted when course is saved).
  final List<_StagedTopic> _stagedTopics = [];

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    hoursController.dispose();
    _topicNameController.dispose();
    _topicHoursController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  double get _courseHours => double.tryParse(hoursController.text.trim()) ?? 0;

  double get _allocatedHours =>
      _stagedTopics.fold<double>(0, (sum, t) => sum + t.hours);

  bool get _budgetExceeded => _allocatedHours > _courseHours && _courseHours > 0;

  // ---------------------------------------------------------------------------
  // Topic management
  // ---------------------------------------------------------------------------

  void _addTopic() {
    final name = _topicNameController.text.trim();
    final hours = double.tryParse(_topicHoursController.text.trim());

    if (name.isEmpty) {
      _showSnack('Enter a topic name.');
      return;
    }
    if (hours == null || hours <= 0) {
      _showSnack('Enter valid study hours for the topic.');
      return;
    }

    final newAllocated = _allocatedHours + hours;
    if (_courseHours > 0 && newAllocated > _courseHours) {
      _showSnack(
        'Adding this topic would exceed the course budget by '
        '${(newAllocated - _courseHours).toStringAsFixed(1)} h.',
      );
      return;
    }

    setState(() {
      _stagedTopics.add(_StagedTopic(name: name, hours: hours));
      _topicNameController.clear();
      _topicHoursController.clear();
    });
  }

  void _removeTopic(int index) {
    setState(() => _stagedTopics.removeAt(index));
  }

  // ---------------------------------------------------------------------------
  // Deadline picker
  // ---------------------------------------------------------------------------

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => selectedDeadline = picked);
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDeadline == null) {
      _showSnack('Select a deadline first.');
      return;
    }
    if (_budgetExceeded) {
      _showSnack('Topic hours exceed estimated course time. Remove or shorten topics.');
      return;
    }

    setState(() => saving = true);

    final courseId = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Create the course
    await CourseService.addCourse(Course(
      id: courseId,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      deadline: selectedDeadline!,
      priority: selectedPriority,
      estimatedHours: double.parse(hoursController.text.trim()),
    ));

    // 2. Persist each staged topic
    for (final staged in _stagedTopics) {
      await CourseService.addTopic(Topic(
        id: '${courseId}_${DateTime.now().microsecondsSinceEpoch}',
        courseId: courseId,
        name: staged.name,
        estimatedHours: staged.hours,
      ));
    }

    if (!mounted) return;
    setState(() => saving = false);
    Navigator.pop(context, true);
  }

  // ---------------------------------------------------------------------------
  // Snackbar helper
  // ---------------------------------------------------------------------------

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: const Text('Create Course'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page, 10, AppSpacing.page, 36,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    Text('Create Course', style: AppTextStyles.display),
                    const SizedBox(height: 5),
                    const Text(
                      'Add the information needed to build your study plan.',
                      style: AppTextStyles.muted,
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // --- Course name ---
                    _label('Course'),
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(hintText: 'Data Structures'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter a course name' : null,
                    ),

                    // --- Description ---
                    const SizedBox(height: AppSpacing.lg),
                    _label('Description'),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Optional description'),
                    ),

                    // --- Estimated hours ---
                    const SizedBox(height: AppSpacing.lg),
                    _label('Estimated study time'),
                    TextFormField(
                      controller: hoursController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '10', suffixText: 'hours'),
                      onChanged: (_) => setState(() {}), // refresh budget bar
                      validator: (v) {
                        final value = double.tryParse(v?.trim() ?? '');
                        return value == null || value <= 0 ? 'Enter a valid number' : null;
                      },
                    ),

                    // --- Deadline ---
                    const SizedBox(height: AppSpacing.lg),
                    _label('Deadline'),
                    InkWell(
                      onTap: _pickDeadline,
                      borderRadius: BorderRadius.circular(10),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          selectedDeadline == null
                              ? 'Select deadline'
                              : '${selectedDeadline!.day.toString().padLeft(2, '0')} ${_month(selectedDeadline!.month)} ${selectedDeadline!.year}',
                          style: selectedDeadline == null
                              ? AppTextStyles.muted
                              : AppTextStyles.body,
                        ),
                      ),
                    ),

                    // --- Priority ---
                    const SizedBox(height: AppSpacing.lg),
                    _label('Priority'),
                    Row(
                      children: ['Low', 'Medium', 'High'].map((priority) {
                        final selected = selectedPriority == priority;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              selected: selected,
                              label: Center(child: Text(priority)),
                              onSelected: (_) =>
                                  setState(() => selectedPriority = priority),
                              selectedColor: AppColors.primaryLight,
                              labelStyle: TextStyle(
                                color: selected ? AppColors.primary : AppColors.text,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: selected ? AppColors.primary : AppColors.divider,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                              showCheckmark: false,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // ===== TOPICS SECTION =====================================
                    const SizedBox(height: AppSpacing.xxl),
                    _label('Topics'),
                    const SizedBox(height: 4),
                    const Text(
                      'Break your course into topics. Each topic has its own study-hour budget.',
                      style: AppTextStyles.muted,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // -- Time-budget indicator --
                    if (_courseHours > 0) ...[
                      _TimeBudgetBar(
                        allocated: _allocatedHours,
                        total: _courseHours,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // -- Staged topic list --
                    if (_stagedTopics.isNotEmpty)
                      ...List.generate(_stagedTopics.length, (i) {
                        final t = _stagedTopics[i];
                        return _TopicTile(
                          name: t.name,
                          hours: t.hours,
                          onRemove: () => _removeTopic(i),
                        );
                      }),

                    // -- Add-topic inline form --
                    const SizedBox(height: AppSpacing.sm),
                    _TopicInlineForm(
                      nameController: _topicNameController,
                      hoursController: _topicHoursController,
                      onAdd: _addTopic,
                    ),

                    // ===== SAVE BUTTON ========================================
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saving ? null : _save,
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Course'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(text.toUpperCase(), style: AppTextStyles.label),
      );

  String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];
}

// =============================================================================
// Private data class for staged topics (not yet persisted)
// =============================================================================

class _StagedTopic {
  final String name;
  final double hours;
  const _StagedTopic({required this.name, required this.hours});
}

// =============================================================================
// Topic inline form widget
// =============================================================================

class _TopicInlineForm extends StatelessWidget {
  const _TopicInlineForm({
    required this.nameController,
    required this.hoursController,
    required this.onAdd,
  });

  final TextEditingController nameController;
  final TextEditingController hoursController;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Topic name',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: hoursController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Hours',
                    suffixText: 'h',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                width: 38,
                child: IconButton.filled(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Topic tile (staged item)
// =============================================================================

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.name,
    required this.hours,
    required this.onRemove,
  });

  final String name;
  final double hours;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.topic_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, style: AppTextStyles.body),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${hours.toStringAsFixed(hours.truncateToDouble() == hours ? 0 : 1)} h',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: AppColors.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Time budget bar
// =============================================================================

class _TimeBudgetBar extends StatelessWidget {
  const _TimeBudgetBar({required this.allocated, required this.total});

  final double allocated;
  final double total;

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? (allocated / total).clamp(0.0, 1.0) : 0.0;
    final exceeded = allocated > total;
    final barColor = exceeded ? AppColors.error : AppColors.primary;
    final remaining = (total - allocated).clamp(0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${allocated.toStringAsFixed(1)} / ${total.toStringAsFixed(1)} h allocated',
              style: TextStyle(
                color: exceeded ? AppColors.error : AppColors.mutedText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!exceeded)
              Text(
                '${remaining.toStringAsFixed(1)} h remaining',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                '${(allocated - total).toStringAsFixed(1)} h over budget!',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

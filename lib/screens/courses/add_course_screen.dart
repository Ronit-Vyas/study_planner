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
<<<<<<< HEAD

  // Topic inline form controllers
  final _topicNameController = TextEditingController();
  final _topicHoursController = TextEditingController();

  DateTime? selectedDeadline;
=======
  final newTopicController = TextEditingController();

  DateTime? selectedDeadline = DateTime.now().add(const Duration(days: 14));
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
  String selectedPriority = 'Medium';
  double newTopicHours = 2.0;
  bool autoGenerateSchedule = true;
  bool autoSumHours = true;
  bool isSaving = false;

  // In-memory topics list before saving
  final List<TopicDraft> topicDrafts = [];

  // Subject presets to dramatically reduce user effort
  final List<CoursePreset> presets = [
    CoursePreset(
      name: 'Data Structures & Algorithms',
      emoji: '💻',
      defaultHours: 12,
      topics: [
        'Arrays, Strings & Hash Tables (2.5h)',
        'Linked Lists, Stacks & Queues (2.5h)',
        'Trees, Graphs & BFS/DFS (3.5h)',
        'Dynamic Programming & Recursion (3.5h)',
      ],
      topicHours: [2.5, 2.5, 3.5, 3.5],
    ),
    CoursePreset(
      name: 'Calculus & Applied Math',
      emoji: '📐',
      defaultHours: 10,
      topics: [
        'Limits & Continuity (2h)',
        'Derivatives & Optimization (3h)',
        'Integrals & Differential Equations (3h)',
        'Practice Problem Sets (2h)',
      ],
      topicHours: [2.0, 3.0, 3.0, 2.0],
    ),
    CoursePreset(
      name: 'Full-Stack Web Dev',
      emoji: '⚡',
      defaultHours: 14,
      topics: [
        'HTML, CSS & Modern Layouts (2.5h)',
        'JavaScript Core & Async/Await (3.5h)',
        'Frontend Framework & State (4h)',
        'REST APIs & Database Integration (4h)',
      ],
      topicHours: [2.5, 3.5, 4.0, 4.0],
    ),
    CoursePreset(
      name: 'Exam Revision & Practice',
      emoji: '📚',
      defaultHours: 8,
      topics: [
        'High-Weightage Key Concepts (2.5h)',
        'Formula Sheet & Summary Notes (1.5h)',
        'Past Exam Papers & Timed Mock (2.5h)',
        'Weak Area Drills & Final Polish (1.5h)',
      ],
      topicHours: [2.5, 1.5, 2.5, 1.5],
    ),
    CoursePreset(
      name: 'Machine Learning Fundamentals',
      emoji: '🤖',
      defaultHours: 12,
      topics: [
        'Data Preprocessing & EDA (2.5h)',
        'Supervised Learning Algorithms (3.5h)',
        'Neural Networks & Deep Learning (3.5h)',
        'Model Evaluation & Deployment (2.5h)',
      ],
      topicHours: [2.5, 3.5, 3.5, 2.5],
    ),
  ];

  /// Topics staged for creation (persisted when course is saved).
  final List<_StagedTopic> _stagedTopics = [];

  @override
<<<<<<< HEAD
=======
  void initState() {
    super.initState();
    hoursController.text = '8';
  }

  @override
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    hoursController.dispose();
<<<<<<< HEAD
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
=======
    newTopicController.dispose();
    super.dispose();
  }

  void _applyPreset(CoursePreset preset) {
    setState(() {
      nameController.text = preset.name;
      hoursController.text = preset.defaultHours.toString();
      topicDrafts.clear();
      for (int i = 0; i < preset.topics.length; i++) {
        final topicName = preset.topics[i].replaceAll(RegExp(r'\s*\(\d+(\.\d+)?h\)$'), '');
        final hours = preset.topicHours[i];
        topicDrafts.add(TopicDraft(name: topicName, hours: hours));
      }
      _syncHours();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied "${preset.name}" preset with ${preset.topics.length} topics!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _syncHours() {
    if (autoSumHours && topicDrafts.isNotEmpty) {
      final total = topicDrafts.fold<double>(0, (sum, t) => sum + t.hours);
      hoursController.text = total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(1);
    }
  }

  void _addTopicDraft() {
    final text = newTopicController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      topicDrafts.add(TopicDraft(name: text, hours: newTopicHours));
      newTopicController.clear();
      _syncHours();
    });
  }

  void _removeTopicDraft(int index) {
    setState(() {
      topicDrafts.removeAt(index);
      _syncHours();
    });
  }

  void _setQuickDeadlineDays(int days) {
    setState(() {
      selectedDeadline = DateTime.now().add(Duration(days: days));
    });
  }
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
<<<<<<< HEAD
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => selectedDeadline = picked);
=======
      initialDate: selectedDeadline ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => selectedDeadline = picked);
    }
  }

  Future<void> _showBulkAddDialog() async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bulk Add Topics / Syllabus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your topics separated by commas or lines (e.g. Chapter 1, Chapter 2, Review):',
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 5,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "1. Intro to Arrays\n2. Trees and Graphs\n3. Dynamic Programming\n4. Final Project",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, textController.text),
            child: const Text('Add All'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      // Split by newline or comma
      final lines = result
          .split(RegExp(r'[\n,]'))
          .map((s) => s.replaceAll(RegExp(r'^\s*(\d+[\.\)]|\-|\*)\s*'), '').trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (lines.isNotEmpty) {
        setState(() {
          for (final line in lines) {
            topicDrafts.add(TopicDraft(name: line, hours: 2.0));
          }
          _syncHours();
        });
      }
    }
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDeadline == null) {
<<<<<<< HEAD
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
=======
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course deadline.')),
      );
      return;
    }

    final totalHours = double.tryParse(hoursController.text.trim()) ?? 10.0;
    final courseId = 'course_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => isSaving = true);

    try {
      final course = Course(
        id: courseId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        deadline: selectedDeadline!,
        priority: selectedPriority,
        estimatedHours: totalHours,
      );

      // Convert drafts to Topic models
      final topics = topicDrafts.map((draft) {
        return Topic(
          id: 'topic_${DateTime.now().microsecondsSinceEpoch}_${draft.name.hashCode.abs()}',
          courseId: courseId,
          name: draft.name,
          estimatedHours: draft.hours,
        );
      }).toList();

      final generatedCount = await CourseService.createCourseWithTopicsAndSchedule(
        course: course,
        topics: topics,
        autoGenerateSchedule: autoGenerateSchedule,
      );

      if (!mounted) return;

      final message = topics.isNotEmpty && autoGenerateSchedule
          ? 'Course created with ${topics.length} topics and $generatedCount study tasks scheduled!'
          : 'Course "${course.name}" created successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating course: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = selectedDeadline == null
        ? 0
        : selectedDeadline!.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create New Course'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 12, AppSpacing.page, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x204F46E5),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_stories, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Setup Course & Topics',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Pick a preset or enter your course. We can build your daily study plan automatically!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Presets
                    _sectionHeader('QUICK SUBJECT TEMPLATES', 'Tap to auto-fill topics instantly'),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: presets.map((preset) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              avatar: Text(preset.emoji, style: const TextStyle(fontSize: 14)),
                              label: Text(preset.name),
                              labelStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.cardBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onPressed: () => _applyPreset(preset),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Course Details Section
                    _cardWrapper(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader('COURSE INFORMATION', null),
                          const SizedBox(height: 14),

                          _label('Course Title *'),
                          TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Advanced Operating Systems',
                              prefixIcon: Icon(Icons.book_outlined, color: AppColors.mutedText),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a course name' : null,
                          ),

                          const SizedBox(height: 16),

                          _label('Description (Optional)'),
                          TextFormField(
                            controller: descriptionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: 'Key objectives, exams, or chapters to cover...',
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Total Hours Estimated'),
                                    TextFormField(
                                      controller: hoursController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: '10',
                                        suffixText: 'hrs',
                                        prefixIcon: const Icon(Icons.timer_outlined, color: AppColors.mutedText),
                                        suffixIcon: autoSumHours && topicDrafts.isNotEmpty
                                            ? const Tooltip(
                                                message: 'Auto-summed from topics',
                                                child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                                              )
                                            : null,
                                      ),
                                      validator: (v) {
                                        final val = double.tryParse(v?.trim() ?? '');
                                        return val == null || val <= 0 ? 'Enter valid hours' : null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Priority'),
                                    Row(
                                      children: ['Low', 'Medium', 'High'].map((p) {
                                        final isSel = selectedPriority == p;
                                        Color activeCol = AppColors.primary;
                                        if (p == 'High') activeCol = AppColors.error;
                                        if (p == 'Medium') activeCol = AppColors.warning;
                                        if (p == 'Low') activeCol = AppColors.success;

                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 4),
                                            child: InkWell(
                                              onTap: () => setState(() => selectedPriority = p),
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                height: 48,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: isSel ? activeCol.withValues(alpha: 0.12) : AppColors.surfaceSubtle,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isSel ? activeCol : AppColors.cardBorder,
                                                    width: isSel ? 1.6 : 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  p,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                                    color: isSel ? activeCol : AppColors.mutedText,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Deadline & Quick Dates
                          _label('Target Deadline'),
                          InkWell(
                            onTap: _pickDeadline,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_outlined, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedDeadline == null
                                          ? 'Select target deadline'
                                          : '${selectedDeadline!.day.toString().padLeft(2, '0')} ${_month(selectedDeadline!.month)} ${selectedDeadline!.year} ($daysRemaining days from now)',
                                      style: AppTextStyles.bodyBold,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: AppColors.mutedText),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Quick pick: ', style: AppTextStyles.muted),
                              _dateChip('+1 Week', () => _setQuickDeadlineDays(7)),
                              _dateChip('+2 Weeks', () => _setQuickDeadlineDays(14)),
                              _dateChip('+1 Month', () => _setQuickDeadlineDays(30)),
                              _dateChip('+2 Months', () => _setQuickDeadlineDays(60)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Topics & Syllabus Section (Integrated!)
                    _cardWrapper(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionHeader('COURSE TOPICS & SYLLABUS', 'Add topics right now so you don\'t have to do it later'),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _showBulkAddDialog,
                                icon: const Icon(Icons.paste, size: 15),
                                label: const Text('Bulk Add'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: const Size(0, 36),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Inline Add Topic Input
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: newTopicController,
                                    textCapitalization: TextCapitalization.sentences,
                                    onSubmitted: (_) => _addTopicDraft(),
                                    decoration: const InputDecoration(
                                      hintText: 'Type topic name (e.g. Chapter 1: Foundations)',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: DropdownButton<double>(
                                    value: newTopicHours,
                                    underline: const SizedBox(),
                                    items: const [
                                      DropdownMenuItem(value: 0.5, child: Text('0.5h')),
                                      DropdownMenuItem(value: 1.0, child: Text('1.0h')),
                                      DropdownMenuItem(value: 1.5, child: Text('1.5h')),
                                      DropdownMenuItem(value: 2.0, child: Text('2.0h')),
                                      DropdownMenuItem(value: 3.0, child: Text('3.0h')),
                                      DropdownMenuItem(value: 4.0, child: Text('4.0h')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => newTopicHours = val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _addTopicDraft,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(44, 44),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  child: const Icon(Icons.add, size: 20),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Topics list preview
                          if (topicDrafts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.layers_outlined, size: 36, color: Colors.grey.shade400),
                                    const SizedBox(height: 6),
                                    const Text('No topics added yet', style: AppTextStyles.bodyBold),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Add individual topics above or choose a Quick Template!',
                                      style: AppTextStyles.muted,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${topicDrafts.length} topics prepared · ${topicDrafts.fold<double>(0, (s, t) => s + t.hours).toStringAsFixed(1)}h total',
                                      style: AppTextStyles.muted,
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: autoSumHours,
                                          onChanged: (v) {
                                            setState(() {
                                              autoSumHours = v ?? true;
                                              _syncHours();
                                            });
                                          },
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        const Text('Auto-sum hours', style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: topicDrafts.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final draft = topicDrafts[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.cardBorder),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(draft.name, style: AppTextStyles.bodyBold),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceSubtle,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${draft.hours % 1 == 0 ? draft.hours.toInt() : draft.hours}h',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 18, color: AppColors.mutedText),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _removeTopicDraft(index),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Automation Switch Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: autoGenerateSchedule ? AppColors.primaryLight.withValues(alpha: 0.5) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: autoGenerateSchedule ? AppColors.primary.withValues(alpha: 0.3) : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: autoGenerateSchedule ? AppColors.primary : AppColors.mutedText,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Auto-Generate Study Plan', style: AppTextStyles.bodyBold),
                                SizedBox(height: 2),
                                Text(
                                  'Instantly schedule daily study sessions up to your deadline.',
                                  style: AppTextStyles.muted,
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: autoGenerateSchedule,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) => setState(() => autoGenerateSchedule = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    topicDrafts.isNotEmpty && autoGenerateSchedule
                                        ? 'Create Course & Generate Schedule'
                                        : 'Create Course',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
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

  Widget _cardWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.label.copyWith(color: AppColors.primary)),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle, style: AppTextStyles.muted),
        ],
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
    );
  }

  Widget _dateChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ),
    );
  }

  String _month(int m) => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}

class TopicDraft {
  final String name;
  final double hours;

  TopicDraft({required this.name, required this.hours});
}

class CoursePreset {
  final String name;
  final String emoji;
  final double defaultHours;
  final List<String> topics;
  final List<double> topicHours;

  CoursePreset({
    required this.name,
    required this.emoji,
    required this.defaultHours,
    required this.topics,
    required this.topicHours,
  });
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
}

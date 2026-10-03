import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/models/note_model.dart';
import '../../providers/app_provider.dart';

class NotesScreen extends StatefulWidget {
  final String? initialCourseId;

  const NotesScreen({super.key, this.initialCourseId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String? _filterCourseId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filterCourseId = widget.initialCourseId;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final courses = provider.activeCourses;

    var notes = provider.notes;
    if (_filterCourseId != null) {
      notes = notes.where((n) => n.courseId == _filterCourseId).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      notes = notes
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.content.toLowerCase().contains(q))
          .toList();
    }

    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Notes & Revision'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteEditor(context, null),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('New Note', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.sm,
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search notes by keyword...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
              ),
            ),

            // Subject Filter Chips
            if (courses.isNotEmpty) ...[
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  children: [
                    ChoiceChip(
                      label: const Text('All Subjects'),
                      selected: _filterCourseId == null,
                      onSelected: (_) => setState(() => _filterCourseId = null),
                    ),
                    const SizedBox(width: 8),
                    ...courses.map((c) {
                      final isSel = _filterCourseId == c.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(c.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          label: Text(c.name),
                          selected: isSel,
                          onSelected: (_) =>
                              setState(() => _filterCourseId = isSel ? null : c.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Notes Grid / List
            Expanded(
              child: notes.isEmpty
                  ? AppEmptyState(
                      icon: Icons.note_alt_outlined,
                      title: 'No Notes Found',
                      message: _searchQuery.isNotEmpty
                          ? 'No notes match "$_searchQuery".'
                          : 'Write quick revision summaries, formulas, and cheat sheets for your subjects.',
                      action: ElevatedButton.icon(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => _openNoteEditor(context, null),
                        label: const Text('Create First Note'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.sm,
                        AppSpacing.page,
                        80,
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _NoteCard(
                          note: note,
                          onTap: () => _openNoteEditor(context, note),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNoteEditor(BuildContext context, StudyNote? existingNote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NoteEditorSheet(existingNote: existingNote),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final StudyNote note;
  final VoidCallback onTap;

  const _NoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final course = provider.courses.cast<dynamic>().firstWhere(
          (c) => c.id == note.courseId,
          orElse: () => null,
        );

    final courseColor = course != null ? Color(course.colorValue) : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (course != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: courseColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    course.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: courseColor,
                    ),
                  ),
                ] else
                  Text('General Note', style: AppTextStyles.caption),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(note.updatedAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(note.title, style: AppTextStyles.title),
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                note.content,
                maxLines: 3,
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
}

class _NoteEditorSheet extends StatefulWidget {
  final StudyNote? existingNote;

  const _NoteEditorSheet({this.existingNote});

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String? _courseId;

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleCtrl.text = widget.existingNote!.title;
      _contentCtrl.text = widget.existingNote!.content;
      _courseId = widget.existingNote!.courseId;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final provider = context.read<AppProvider>();

    if (widget.existingNote != null) {
      final updated = widget.existingNote!.copyWith(
        title: title,
        content: _contentCtrl.text.trim(),
        courseId: _courseId,
      );
      await provider.updateNote(updated);
    } else {
      final note = StudyNote(
        id: provider.newId(),
        title: title,
        content: _contentCtrl.text.trim(),
        courseId: _courseId,
      );
      await provider.addNote(note);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final courses = provider.activeCourses;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.page,
        AppSpacing.page,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.page,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.existingNote != null ? 'Edit Note' : 'New Note',
                style: AppTextStyles.subtitle,
              ),
              const Spacer(),
              if (widget.existingNote != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  onPressed: () async {
                    await provider.deleteNote(widget.existingNote!.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Course dropdown
          if (courses.isNotEmpty)
            DropdownButtonFormField<String?>(
              initialValue: _courseId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Linked Subject (Optional)',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('General (No Subject)')),
                ...courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setState(() => _courseId = v),
            ),
          const SizedBox(height: 12),

          // Title
          TextField(
            controller: _titleCtrl,
            style: AppTextStyles.title,
            decoration: const InputDecoration(
              hintText: 'Note Title...',
              border: InputBorder.none,
            ),
          ),
          const Divider(),

          // Content
          Expanded(
            child: TextField(
              controller: _contentCtrl,
              maxLines: null,
              expands: true,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'Start typing notes, formulas, key definitions...',
                border: InputBorder.none,
              ),
            ),
          ),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

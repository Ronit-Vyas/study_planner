import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_section.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/course_card.dart';
import 'add_course_screen.dart';
import 'course_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> courses = [];
  bool isLoading = true;

  @override
  void initState() { super.initState(); _loadCourses(); }

  Future<void> _loadCourses() async {
    if (mounted) setState(() => isLoading = true);
    final loaded = await CourseService.getAllCourses();
    if (!mounted) return;
    setState(() { courses = loaded; isLoading = false; });
  }

  Future<void> _add() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourseScreen()));
    if (result == true) await _loadCourses();
  }

  Future<void> _details(Course course) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: course)));
    if (result == true) await _loadCourses();
  }

  Future<void> _delete(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete course?'),
        content: Text('This will remove ${course.name} from your local study plan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await CourseService.deleteCourse(course.id);
      await _loadCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 900 ? 760.0 : double.infinity;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, 22, AppSpacing.page, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('My Courses', style: AppTextStyles.display)),
                          IconButton(onPressed: _add, icon: const Icon(Icons.add), color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${courses.length} ${courses.length == 1 ? 'course' : 'courses'}', style: AppTextStyles.muted),
                      const SizedBox(height: AppSpacing.section),
                      if (isLoading)
                        const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()))
                      else if (courses.isEmpty)
                        AppSection(
                          title: 'Courses',
                          child: EmptyState(
                            icon: Icons.menu_book_outlined,
                            title: 'No courses yet',
                            message: 'Add your first course and build a focused study plan.',
                            action: ElevatedButton.icon(onPressed: _add, icon: const Icon(Icons.add, size: 18), label: const Text('Add course')),
                          ),
                          dividerAfter: false,
                        )
                      else
                        AppSection(
                          title: 'Courses',
                          child: Column(
                            children: [
                              for (int i = 0; i < courses.length; i++) ...[
                                CourseCard(course: courses[i], onTap: () => _details(courses[i]), onDelete: () => _delete(courses[i])),
                                if (i != courses.length - 1) const Divider(),
                              ],
                            ],
                          ),
                          dividerAfter: false,
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
}

import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
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
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    if (mounted) setState(() => isLoading = true);
    final loaded = await CourseService.getAllCourses();
    if (!mounted) return;
    setState(() {
      courses = loaded;
      isLoading = false;
    });
  }

  Future<void> _add() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCourseScreen()),
    );
    if (result == true) await _loadCourses();
  }

  Future<void> _details(Course course) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: course)),
    );
    if (result == true) await _loadCourses();
  }

  Future<void> _delete(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete course?'),
        content: Text('This will remove "${course.name}" and all its scheduled tasks.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await CourseService.deleteCourse(course.id);
      await _loadCourses();
    }
  }

  List<Course> get filteredCourses {
    return courses.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (selectedFilter == 'High') return c.priority.toLowerCase() == 'high';
      if (selectedFilter == 'Medium') return c.priority.toLowerCase() == 'medium';
      if (selectedFilter == 'Low') return c.priority.toLowerCase() == 'low';

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadCourses,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 900 ? 760.0 : double.infinity;
            final displayList = filteredCourses;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.page, 20, AppSpacing.page, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('My Courses', style: AppTextStyles.hero),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${courses.length} ${courses.length == 1 ? 'course' : 'courses'} enrolled',
                                    style: AppTextStyles.muted,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _add,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New Course'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Search and Filter Bar
                        if (courses.isNotEmpty) ...[
                          TextField(
                            onChanged: (val) => setState(() => searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search courses by name or topic...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.cardBorder),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['All', 'High', 'Medium', 'Low'].map((filter) {
                                final isSelected = selectedFilter == filter;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(filter == 'All' ? 'All Priorities' : '$filter Priority'),
                                    selected: isSelected,
                                    onSelected: (_) => setState(() => selectedFilter = filter),
                                    selectedColor: AppColors.primaryLight,
                                    labelStyle: TextStyle(
                                      color: isSelected ? AppColors.primary : AppColors.text,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    showCheckmark: false,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Course List or Loading / Empty States
                        if (isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(50),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (courses.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: EmptyState(
                              icon: Icons.menu_book_rounded,
                              title: 'Start by adding a course',
                              message: 'Add your subjects and topics in one click to build an automated study schedule.',
                              action: ElevatedButton.icon(
                                onPressed: _add,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Create Your First Course'),
                              ),
                            ),
                          )
                        else if (displayList.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: const Text('No courses match your search or filter.', style: AppTextStyles.muted),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayList.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final course = displayList[index];
                              return CourseCard(
                                course: course,
                                onTap: () => _details(course),
                                onDelete: () => _delete(course),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

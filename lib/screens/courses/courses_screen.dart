import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../services/course_service.dart';
import '../../widgets/course_card.dart';
import 'add_course_screen.dart';
import 'course_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() =>
      _CoursesScreenState();
}

class _CoursesScreenState
    extends State<CoursesScreen> {

  // This is the actual list displayed by the UI.
  List<Course> courses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      isLoading = true;
    });

    final loadedCourses =
    await CourseService.getAllCourses();

    if (!mounted) return;

    setState(() {
      courses = loadedCourses;
      isLoading = false;
    });
  }

  Future<void> _openAddCourse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddCourseScreen(),
      ),
    );

    if (result == true) {
      await _loadCourses();
    }
  }

  Future<void> _openCourseDetails(
      Course course,
      ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailsScreen(
          course: course,
        ),
      ),
    );

    if (result == true) {
      await _loadCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Courses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _buildBody(),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _openAddCourse,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (courses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final Course course = courses[index];

        return CourseCard(
          course: course,

          onTap: () {
            _openCourseDetails(course);
          },

          onDelete: () async {
            await CourseService.deleteCourse(
              course.id,
            );

            await _loadCourses();
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Courses Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Add your first course and we\'ll '
                  'create your study plan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: _openAddCourse,
              icon: const Icon(Icons.add),
              label: const Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }
}
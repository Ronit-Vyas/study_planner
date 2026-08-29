import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../widgets/course_card.dart';
import 'add_course_screen.dart';
import 'course_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  Widget build(BuildContext context) {
    final courses = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Courses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: courses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final Course course = courses[index];

          return CourseCard(
            course: course,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailsScreen(
                    course: course,
                  ),
                ),
              );

              setState(() {});
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddCourseScreen(),
            ),
          );

          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Add your first course and we\'ll create your study plan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddCourseScreen(),
                  ),
                );

                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../utils/helpers.dart';
import '../../widgets/priority_badge.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;

  const CourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        course.deadline.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  PriorityBadge(
                    priority: course.priority,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              course.description.isEmpty
                  ? 'No description provided.'
                  : course.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            _infoCard(
              Icons.calendar_month,
              'Deadline',
              formatDate(course.deadline),
            ),

            _infoCard(
              Icons.access_time,
              'Estimated Time',
              '${course.estimatedHours} hours',
            ),

            _infoCard(
              Icons.timer_outlined,
              'Days Remaining',
              daysLeft < 0 ? 'Deadline passed' : '$daysLeft days',
            ),

            const SizedBox(height: 20),

            const Text(
              'Study Progress',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: 0,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 8),

            const Text('0% completed'),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
      IconData icon,
      String title,
      String value,
      ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../services/firestore_service.dart';
import 'priority_badge.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final topics =
    FirestoreService.getTopicsForCourse(course.id);

    final totalHours = topics.fold<double>(
      0,
          (sum, topic) => sum + topic.estimatedHours,
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  PriorityBadge(
                    priority: course.priority,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                course.description.isEmpty
                    ? 'No description'
                    : course.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  const Icon(
                    Icons.topic_outlined,
                    size: 17,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    '${topics.length} topics',
                  ),

                  const SizedBox(width: 15),

                  const Icon(
                    Icons.access_time,
                    size: 17,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    '$totalHours hrs',
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    '${course.deadline.day}/'
                        '${course.deadline.month}/'
                        '${course.deadline.year}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../utils/helpers.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Find the related course
    final course = FirestoreService.courses
        .where((course) => course.id == task.courseId)
        .firstOrNull;

    // Find the related topic
    final topic = FirestoreService.topics
        .where((topic) => topic.id == task.topicId)
        .firstOrNull;

    final courseName = course?.name ?? 'Unknown Course';
    final topicName = topic?.name ?? 'Unknown Topic';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Row(
          children: [
            Checkbox(
              value: task.completed,
              onChanged: (_) {
                onChanged();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic name
                  Text(
                    topicName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Course name
                  Text(
                    courseName,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 15,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${task.duration} hours',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(width: 12),

                      PriorityBadge(
                        priority: course?.priority ?? 'Medium',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
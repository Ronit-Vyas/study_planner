import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/course_service.dart';
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
    return FutureBuilder(
      future: Future.wait([
        CourseService.getCourseById(task.courseId),
        CourseService.getTopicById(task.topicId),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Unable to load task details',
              ),
            ),
          );
        }

        final results = snapshot.data!;

        final course = results[0] as dynamic;
        final topic = results[1] as dynamic;

        final courseName =
            course?.name ?? 'Unknown Course';

        final topicName =
            topic?.name ?? 'Unknown Topic';

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
                  onChanged: (_) => onChanged(),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(5),
                  ),
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
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
                            priority:
                            course?.priority ??
                                'Medium',
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
      },
    );
  }
}
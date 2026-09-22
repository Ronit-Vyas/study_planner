import 'package:flutter/material.dart';

import '../../models/course_model.dart';
import '../../services/course_service.dart';
import '../../widgets/priority_badge.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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

                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ];
                    },
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
                    Icons.access_time,
                    size: 17,
                  ),
                  const SizedBox(width: 5),

                  FutureBuilder(
                    future: CourseService.getTopicsForCourse(
                      course.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          width: 30,
                          height: 15,
                          child: LinearProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Text('0 hrs');
                      }

                      final topics = snapshot.data!;

                      final totalHours =
                      topics.fold<double>(
                        0,
                            (sum, topic) =>
                        sum + topic.estimatedHours,
                      );

                      return Text(
                        '$totalHours hrs',
                      );
                    },
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
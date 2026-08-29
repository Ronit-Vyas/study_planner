import 'package:flutter/material.dart';

import '../../widgets/task_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasks = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              10,
            ),
            child: Row(
              children: [
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  '${tasks.length} tasks',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: tasks.isEmpty
                ? Center(
              child: Text(
                'No study tasks for this day.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return TaskCard(
                  task: task,
                  onChanged: () {
                    setState(() {
                      task.completed = !task.completed;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
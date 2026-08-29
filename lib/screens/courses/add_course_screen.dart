import 'package:flutter/material.dart';

import '../../models/course_model.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final hoursController = TextEditingController();

  DateTime? selectedDeadline;

  String selectedPriority = 'Medium';

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    hoursController.dispose();

    super.dispose();
  }

  Future<void> selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(
        const Duration(days: 7),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }

  void saveCourse() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a deadline'),
        ),
      );

      return;
    }

    final course = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      deadline: selectedDeadline!,
      priority: selectedPriority,
      estimatedHours:
      double.tryParse(hoursController.text.trim()) ?? 1,
    );


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course added successfully'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Course',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Course Name'),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Data Structures',
                  prefixIcon: Icon(Icons.menu_book),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter course name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Description'),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'What do you want to study?',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel('Estimated Study Hours'),

              TextFormField(
                controller: hoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g. 10',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                  suffixText: 'hours',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter estimated hours';
                  }

                  final hours = double.tryParse(value);

                  if (hours == null || hours <= 0) {
                    return 'Enter a valid number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Priority'),

              DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'High',
                    child: Text('High'),
                  ),
                  DropdownMenuItem(
                    value: 'Medium',
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 'Low',
                    child: Text('Low'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Deadline'),

              InkWell(
                onTap: selectDeadline,
                borderRadius: BorderRadius.circular(5),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    selectedDeadline == null
                        ? 'Select deadline'
                        : '${selectedDeadline!.day}/'
                        '${selectedDeadline!.month}/'
                        '${selectedDeadline!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: saveCourse,
                  child: const Text(
                    'Create Course',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
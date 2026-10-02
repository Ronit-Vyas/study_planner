import 'package:flutter/material.dart';
import 'constants.dart';

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String formatShortDate(DateTime date) {
  return '${date.day}/${date.month}';
}

String formatDisplayDate(DateTime date) {
  return '${shortMonthName(date.month)} ${date.day}';
}

String priorityText(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return 'High';
    case 'medium':
      return 'Medium';
    case 'low':
      return 'Low';
    default:
      return 'Medium';
  }
}

Color priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return AppColors.highPriority;
    case 'medium':
      return AppColors.mediumPriority;
    case 'low':
      return AppColors.lowPriority;
    default:
      return AppColors.mutedText;
  }
}

String monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return months[month - 1];
}

String shortMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return months[month - 1];
}

String weekdayShort(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}
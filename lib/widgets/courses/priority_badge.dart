import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool compact;

  const PriorityBadge({super.key, required this.priority, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(priority);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 9, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priorityText(priority),
        style: TextStyle(color: color, fontSize: compact ? 10 : 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

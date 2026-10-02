import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool expanded;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
          );

    final button = outlined
        ? OutlinedButton(onPressed: onPressed, child: child)
        : ElevatedButton(onPressed: onPressed, child: child);

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

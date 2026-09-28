import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class AppSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  final bool dividerAfter;

  const AppSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.dividerAfter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title.toUpperCase(), style: AppTextStyles.label)),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        child,
        if (dividerAfter) ...[
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
        ],
      ],
    );
  }
}

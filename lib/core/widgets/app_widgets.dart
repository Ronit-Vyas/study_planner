import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

/// Section header with title, optional trailing widget, and optional divider.
class AppSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  const AppSection({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
    this.showDivider = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            children: [
              Text(title, style: AppTextStyles.subtitle),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        child,
        if (showDivider) const SizedBox(height: AppSpacing.section),
      ],
    );
  }
}

/// Glassmorphism-style card with gradient border.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasBorder;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 20,
    this.hasBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder ? Border.all(color: border, width: 1) : null,
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}

/// Priority badge chip.
class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        priority.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: color, fontSize: 10),
      ),
    );
  }

  (Color, Color) _colors() {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return (AppColors.urgent, AppColors.errorBg);
      case 'high':
        return (AppColors.high, AppColors.warningBg);
      case 'medium':
        return (AppColors.medium, AppColors.warningBg);
      case 'low':
        return (AppColors.low, AppColors.successBg);
      default:
        return (AppColors.medium, AppColors.warningBg);
    }
  }
}

/// Animated progress bar.
class AppProgressBar extends StatefulWidget {
  final double value; // 0.0 – 1.0
  final Color? color;
  final double height;
  final bool showLabel;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
    this.showLabel = false,
  });

  @override
  State<AppProgressBar> createState() => _AppProgressBarState();
}

class _AppProgressBarState extends State<AppProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0, end: widget.value.clamp(0, 1))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AppProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(begin: _anim.value, end: widget.value.clamp(0, 1))
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor =
        isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight2;
    final barColor = widget.color ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: _anim.value,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: widget.height,
            ),
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 4),
            Text(
              '${(_anim.value * 100).toInt()}%',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}

/// Stat card showing a number + label with optional icon.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? bgColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = bgColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final ic = iconColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ic.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: ic),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.statMedium),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

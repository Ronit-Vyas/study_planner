import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(color: AppColors.divider, height: 1);
}

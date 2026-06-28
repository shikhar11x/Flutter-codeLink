import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.06),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.code_rounded,
            color: AppColors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text('CodeLink', style: AppTheme.heading1),
        const SizedBox(height: 8),
        const Text('Real-time collaborative code editor', style: AppTheme.body),
      ],
    );
  }
}

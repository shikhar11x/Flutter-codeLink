import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Glowing icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.gradientGreen,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.code_rounded, color: Colors.black, size: 36),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.gradientGreen.createShader(bounds),
          child: const Text('CodeLink', style: AppTheme.heading1),
        ),
        const SizedBox(height: 8),
        const Text(
          'Real-time collaborative code editor',
          style: AppTheme.body,
        ),
      ],
    );
  }
}
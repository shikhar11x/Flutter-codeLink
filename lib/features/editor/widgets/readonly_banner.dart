import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ReadOnlyBanner extends StatelessWidget {
  const ReadOnlyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7),
      color: AppColors.blue.withOpacity(0.1),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_rounded, size: 13, color: AppColors.blue),
          SizedBox(width: 6),
          Text(
            'View only — editing is disabled',
            style: TextStyle(color: AppColors.blue, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
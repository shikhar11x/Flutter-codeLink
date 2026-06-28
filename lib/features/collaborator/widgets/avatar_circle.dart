import 'package:flutter/material.dart';
import '../models/collaborator_model.dart';
import '../../../core/constants/app_colors.dart';

class AvatarCircle extends StatelessWidget {
  final Collaborator collaborator;
  final double size;

  const AvatarCircle({super.key, required this.collaborator, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collaborator.name,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: collaborator.color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface, width: 2),
          boxShadow: [
            BoxShadow(
              color: collaborator.color.withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            collaborator.initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/collaborator_model.dart';
import '../../../core/constants/app_colors.dart';
import 'avatar_circle.dart';

class AvatarGroup extends StatelessWidget {
  final List<Collaborator> collaborators;
  final double size;
  final double overlap;

  const AvatarGroup({
    super.key,
    required this.collaborators,
    this.size = 32,
    this.overlap = 10,
  });

  @override
  Widget build(BuildContext context) {
    final visible = collaborators.take(4).toList();
    final extra   = collaborators.length - visible.length;
    final width   = (visible.length + (extra > 0 ? 1 : 0)) * (size - overlap) + overlap;

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          ...visible.asMap().entries.map((e) => Positioned(
            left: e.key * (size - overlap),
            child: AvatarCircle(collaborator: e.value, size: size),
          )),
          if (extra > 0)
            Positioned(
              left: visible.length * (size - overlap),
              child: Tooltip(
                message: '+$extra more',
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '+$extra',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
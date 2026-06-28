import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum UserRole { owner, editor, viewer }

class PermissionBadge extends StatelessWidget {
  final UserRole role;

  const PermissionBadge({super.key, required this.role});

  String get _label => switch (role) {
    UserRole.owner  => 'Owner',
    UserRole.editor => 'Editor',
    UserRole.viewer => 'Viewer',
  };

  Color get _color => switch (role) {
    UserRole.owner  => AppColors.purple,
    UserRole.editor => AppColors.green,
    UserRole.viewer => AppColors.blue,
  };

  IconData get _icon => switch (role) {
    UserRole.owner  => Icons.shield_rounded,
    UserRole.editor => Icons.edit_rounded,
    UserRole.viewer => Icons.visibility_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11, color: _color),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
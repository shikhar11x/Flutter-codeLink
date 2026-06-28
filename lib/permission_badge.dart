import 'package:flutter/material.dart';

enum UserRole { owner, editor, viewer }

class PermissionBadge extends StatelessWidget {
  final UserRole role;

  const PermissionBadge({super.key, required this.role});

  String get _label {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.editor:
        return 'Editor';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  Color get _color {
    switch (role) {
      case UserRole.owner:
        return const Color(0xFF8957E5);
      case UserRole.editor:
        return const Color(0xFF238636);
      case UserRole.viewer:
        return const Color(0xFF1F6FEB);
    }
  }

  IconData get _icon {
    switch (role) {
      case UserRole.owner:
        return Icons.shield_outlined;
      case UserRole.editor:
        return Icons.edit_outlined;
      case UserRole.viewer:
        return Icons.visibility_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
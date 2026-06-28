import 'package:flutter/material.dart';

// Ek collaborator ka data
class Collaborator {
  final String id;
  final String name;
  final Color color;

  const Collaborator({
    required this.id,
    required this.name,
    required this.color,
  });

  // Name ke pehle 2 letters (initials)
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

// Single avatar circle
class CollaboratorAvatar extends StatelessWidget {
  final Collaborator collaborator;
  final double size;

  const CollaboratorAvatar({
    super.key,
    required this.collaborator,
    this.size = 32,
  });

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
          border: Border.all(
            color: const Color(0xFF161B22),
            width: 2,
          ),
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

// Overlapping avatars group (jaise Google Docs mein)
class CollaboratorAvatarGroup extends StatelessWidget {
  final List<Collaborator> collaborators;
  final double size;
  final double overlap;

  const CollaboratorAvatarGroup({
    super.key,
    required this.collaborators,
    this.size = 32,
    this.overlap = 10,
  });

  @override
  Widget build(BuildContext context) {
    // Max 4 avatars dikhao, baaki "+N" mein
    final visible = collaborators.take(4).toList();
    final extra = collaborators.length - visible.length;
    final totalWidth = (visible.length + (extra > 0 ? 1 : 0)) * (size - overlap) + overlap;

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: [
          // Visible avatars
          ...visible.asMap().entries.map((entry) {
            final index = entry.key;
            final collaborator = entry.value;
            return Positioned(
              left: index * (size - overlap),
              child: CollaboratorAvatar(
                collaborator: collaborator,
                size: size,
              ),
            );
          }),

          // "+N" circle agar zyada log hain
          if (extra > 0)
            Positioned(
              left: visible.length * (size - overlap),
              child: Tooltip(
                message: '$extra more collaborator${extra > 1 ? 's' : ''}',
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: const Color(0xFF30363D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF161B22),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+$extra',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: size * 0.3,
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
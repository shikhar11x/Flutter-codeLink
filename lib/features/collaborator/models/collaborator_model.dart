import 'package:flutter/material.dart';

class Collaborator {
  final String id;
  final String name;
  final Color color;

  const Collaborator({
    required this.id,
    required this.name,
    required this.color,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
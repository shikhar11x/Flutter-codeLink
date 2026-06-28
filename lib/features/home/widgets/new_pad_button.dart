import 'package:flutter/material.dart';

class NewPadButton extends StatelessWidget {
  final VoidCallback onTap;

  const NewPadButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.06),
              blurRadius: 48,
              spreadRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.black, size: 18),
            SizedBox(width: 8),
            Text(
              'New Pad',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

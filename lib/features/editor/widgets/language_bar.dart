import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LanguageBar extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  static const languages = ['Python', 'JavaScript', 'C++', 'Java', 'Dart'];

  const LanguageBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: languages.map((lang) {
            final isSelected = selected == lang;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.gradientGreen : null,
                    color: isSelected ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(
                            color: AppColors.green.withOpacity(0.3),
                            blurRadius: 8,
                          )]
                        : null,
                  ),
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
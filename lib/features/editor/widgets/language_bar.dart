import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LanguageBar extends StatefulWidget {
  final String selected;
  final Function(String) onChanged;
  final Function(String)? onFileNameChanged;

  static const languages = ['Java', 'Python', 'JavaScript', 'C++', 'Dart'];

  const LanguageBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.onFileNameChanged,
  });

  @override
  State<LanguageBar> createState() => _LanguageBarState();
}

class _LanguageBarState extends State<LanguageBar> {
  bool _editingFileName = false;
  late TextEditingController _fileController;

  static const _defaultFiles = {
    'Java':       'Main.java',
    'Python':     'main.py',
    'JavaScript': 'index.js',
    'C++':        'main.cpp',
    'Dart':       'main.dart',
  };

  String _fileName = 'Main.java';

  @override
  void initState() {
    super.initState();
    _fileName = _defaultFiles[widget.selected] ?? 'main';
    _fileController = TextEditingController(text: _fileName);
  }

  @override
  void didUpdateWidget(LanguageBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      setState(() {
        _fileName = _defaultFiles[widget.selected] ?? 'main';
        _fileController.text = _fileName;
      });
    }
  }

  @override
  void dispose() {
    _fileController.dispose();
    super.dispose();
  }

  void _startEdit() => setState(() => _editingFileName = true);

  void _stopEdit() {
    final name = _fileController.text.trim();
    setState(() {
      _editingFileName = false;
      _fileName = name.isEmpty
          ? (_defaultFiles[widget.selected] ?? 'main')
          : name;
      _fileController.text = _fileName;
    });
    widget.onFileNameChanged?.call(_fileName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File name chip
          GestureDetector(
            onTap: _startEdit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _editingFileName
                    ? AppColors.green.withValues(alpha: 0.1)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _editingFileName
                      ? AppColors.green.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: _editingFileName
                  ? SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _fileController,
                        autofocus: true,
                        onSubmitted: (_) => _stopEdit(),
                        onTapOutside: (_) => _stopEdit(),
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          size: 11,
                          color: AppColors.green.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _fileName,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_rounded,
                          size: 9,
                          color: AppColors.textMuted.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // Divider
          Container(
            width: 1,
            height: 16,
            color: AppColors.border,
          ),

          const SizedBox(width: 8),

          // Language chips
          ...LanguageBar.languages.map((lang) {
            final isSelected = widget.selected == lang;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => widget.onChanged(lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.white.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
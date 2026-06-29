import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PadTitle extends StatefulWidget {
  final String padSlug;
  final Function(String) onTitleChanged;

  const PadTitle({
    super.key,
    required this.padSlug,
    required this.onTitleChanged,
  });

  @override
  State<PadTitle> createState() => _PadTitleState();
}

class _PadTitleState extends State<PadTitle> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.padSlug;
    _controller = TextEditingController(text: _title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _stopEditing() {
    setState(() {
      _isEditing = false;
      _title = _controller.text.trim().isEmpty
          ? widget.padSlug
          : _controller.text.trim();
      _controller.text = _title;
    });
    widget.onTitleChanged(_title);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startEditing,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _isEditing
              ? AppColors.white.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isEditing
                ? AppColors.green.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: _isEditing
            ? SizedBox(
                width: 180,
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onSubmitted: (_) => _stopEditing(),
                  onTapOutside: (_) => _stopEditing(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
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
                  Flexible(
                    child: Text(
                      _title,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_rounded,
                    size: 11,
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                  ),
                ],
              ),
      ),
    );
  }
}
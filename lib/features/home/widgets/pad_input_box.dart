import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/slug_generator.dart';

class PadInputBox extends StatefulWidget {
  final Function(String) onSubmit;

  const PadInputBox({super.key, required this.onSubmit});

  @override
  State<PadInputBox> createState() => _PadInputBoxState();
}

class _PadInputBoxState extends State<PadInputBox> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _go() {
    final raw = _controller.text.trim();
    final slug = raw.isEmpty
        ? SlugGenerator.generate()
        : raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '-');
    widget.onSubmit(slug);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'codelink.app/',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _go(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText: 'your-pad-name',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _go,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.whiteDim,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.white.withOpacity(0.12),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Text(
              'Go!',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
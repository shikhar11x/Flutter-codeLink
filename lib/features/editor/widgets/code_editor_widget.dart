import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../core/constants/app_colors.dart';

class CodeEditorWidget extends StatelessWidget {
  final CodeController controller;
  final bool readOnly;
  final Function(String)? onChanged;
  final int fontSize;
  final bool showLineNumbers;
  final bool wordWrap;

  const CodeEditorWidget({
    super.key,
    required this.controller,
    this.readOnly = false,
    this.onChanged,
    this.fontSize = 14,
    this.showLineNumbers = true,
    this.wordWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return CodeTheme(
      data: CodeThemeData(styles: atomOneDarkTheme),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            CodeField(
              controller: controller,
              readOnly: readOnly,
              onChanged: onChanged,
              wrap: wordWrap,
              textStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: fontSize.toDouble(),
                height: 1.6,
              ),
              gutterStyle: GutterStyle(
                width: showLineNumbers ? 48 : 0,
                margin: showLineNumbers ? 8 : 0,
                showLineNumbers: showLineNumbers,
                textStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: fontSize.toDouble() - 1,
                ),
                background: AppColors.surface,
                textAlign: TextAlign.center,
              ),
              background: AppColors.bg,
              minLines: 30,
            ),

            // Separator line
            if (showLineNumbers)
              Positioned(
                top: 0,
                bottom: 0,
                left: 42,
                child: Container(
                  width: 1,
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
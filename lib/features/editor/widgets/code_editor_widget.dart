import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../core/constants/app_colors.dart';

class CodeEditorWidget extends StatelessWidget {
  final CodeController controller;
  final bool readOnly;

  const CodeEditorWidget({
    super.key,
    required this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return CodeTheme(
      data: CodeThemeData(styles: atomOneDarkTheme),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            // ── Original CodeField — bilkul same as before ──
            CodeField(
              controller: controller,
              readOnly: readOnly,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.6,
              ),
              gutterStyle: const GutterStyle(
                width: 48,
                margin: 8,
                textStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                background: AppColors.surface,
                textAlign: TextAlign.center,
              ),
              background: AppColors.bg,
              minLines: 30,
            ),

            // ── Sirf yeh naya add kiya — separator line ──
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

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/slug_generator.dart';
import '../widgets/home_logo.dart';
import '../widgets/new_pad_button.dart';
import '../widgets/open_pad_dialog.dart';
import '../../editor/screens/editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openEditor(BuildContext context, String slug) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(padSlug: slug)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const HomeLogo(),
              const Spacer(flex: 2),

              NewPadButton(
                onTap: () => _openEditor(context, SlugGenerator.generate()),
              ),
              const SizedBox(height: 16),

              // Open existing pad
              GestureDetector(
                onTap: () async {
                  final slug = await OpenPadDialog.show(context);
                  if (slug != null && context.mounted) {
                    _openEditor(context, slug);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_rounded, color: AppColors.textSecondary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Open Existing Pad',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Footer
              Text(
                'No account needed — just share the link',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
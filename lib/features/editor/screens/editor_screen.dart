import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/dart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../collaborator/models/collaborator_model.dart';
import '../../collaborator/widgets/avatar_group.dart';
import '../../collaborator/widgets/collab_panel.dart';
import '../../collaborator/widgets/permission_badge.dart';
import '../../share/widgets/share_drawer.dart';
import '../../settings/widgets/settings_sheet.dart';
import '../widgets/language_bar.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/readonly_banner.dart';

class EditorScreen extends StatefulWidget {
  final String padSlug;

  const EditorScreen({super.key, required this.padSlug});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String _selectedLanguage = 'Java';
  UserRole _currentRole = UserRole.owner;
  bool _isReadOnly = false;
  String _output = '';
  bool _isRunning = false;
  late CodeController _codeController;

  final List<Collaborator> _collaborators = [
    Collaborator(id: '1', name: 'You', color: Color(0xFFD0D8FF)),
    Collaborator(id: '2', name: 'Alice', color: Color(0xFFFFD0E0)),
    Collaborator(id: '3', name: 'Raj', color: Color(0xFFC8F7DC)),
  ];

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(text: '', language: java);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _changeLanguage(String lang) {
    setState(() {
      _selectedLanguage = lang;
      _codeController = CodeController(
        text: _codeController.text,
        language: switch (lang) {
          'Java' => java,
          'Python' => python,
          'JavaScript' => javascript,
          'C++' => cpp,
          _ => dart,
        },
      );
    });
  }

  void _showShareDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareDrawer(padSlug: widget.padSlug),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SettingsSheet(
        currentRole: _currentRole,
        padSlug: widget.padSlug,
        onReadOnlyChanged: (val) => setState(() => _isReadOnly = val),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.link_rounded,
                color: AppColors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'codelink.app/${widget.padSlug}',
                style: AppTheme.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AvatarGroup(collaborators: _collaborators, size: 28),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: PermissionBadge(role: _currentRole),
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: _showShareDrawer,
            icon: const Icon(
              Icons.share_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Share',
          ),
          IconButton(
            onPressed: _showSettingsSheet,
            icon: const Icon(
              Icons.tune_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Settings',
          ),
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.whiteDim,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.white.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Run',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Main layout ──
          Column(
            children: [
              if (_isReadOnly) const ReadOnlyBanner(),

              // Editor + Collab panel
              Expanded(
                child: Row(
                  children: [
                    // Code editor
                    Expanded(
                      child: CodeEditorWidget(
                        controller: _codeController,
                        readOnly: _isReadOnly,
                      ),
                    ),
                    // Right collab + output panel
                    CollabPanel(
                      collaborators: _collaborators,
                      output: _output,
                      isRunning: _isRunning,
                      language: _selectedLanguage,
                    ),
                  ],
                ),
              ),

              // Bottom padding so editor content doesn't hide behind floating bar
              const SizedBox(height: 64),
            ],
          ),

          // ── Floating language bar — bottom center ──
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: LanguageBar(
                selected: _selectedLanguage,
                onChanged: _changeLanguage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

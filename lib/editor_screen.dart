import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'share_drawer.dart';
import 'collaborator_avatar.dart';
import 'permission_badge.dart';
import 'settings_sheet.dart';

class EditorScreen extends StatefulWidget {
  final String padSlug;

  const EditorScreen({super.key, required this.padSlug});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String _selectedLanguage = 'Python';
  UserRole _currentRole = UserRole.owner;
  bool _isReadOnly = false;
  late CodeController _codeController;

  final List<Collaborator> _collaborators = [
    Collaborator(id: '1', name: 'You', color: const Color(0xFF238636)),
    Collaborator(id: '2', name: 'Alice Smith', color: const Color(0xFF1F6FEB)),
    Collaborator(id: '3', name: 'Raj Kumar', color: const Color(0xFF8957E5)),
  ];

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '',
      language: python,
    );
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
        language: lang == 'Python'
            ? python
            : lang == 'JavaScript'
                ? javascript
                : lang == 'C++'
                    ? cpp
                    : lang == 'Java'
                        ? java
                        : dart,
      );
    });
  }

  void _showShareDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareDrawer(padSlug: widget.padSlug),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SettingsSheet(
        currentRole: _currentRole,
        padSlug: widget.padSlug,
        onReadOnlyChanged: (val) => setState(() => _isReadOnly = val),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Row(
          children: [
            const Icon(Icons.link, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'codelink.app/${widget.padSlug}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Collaborator avatars
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CollaboratorAvatarGroup(
              collaborators: _collaborators,
              size: 32,
              overlap: 10,
            ),
          ),
          const SizedBox(width: 4),

          // Permission badge
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: PermissionBadge(role: _currentRole),
          ),
          const SizedBox(width: 4),

          // Share button
          IconButton(
            onPressed: _showShareDrawer,
            icon: const Icon(Icons.share, size: 18, color: Colors.white70),
            tooltip: 'Share pad',
          ),

          // Settings button
          IconButton(
            onPressed: _showSettingsSheet,
            icon: const Icon(Icons.settings_outlined, size: 18, color: Colors.white70),
            tooltip: 'Settings',
          ),

          // Run button
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('Run'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Read only banner
          if (_isReadOnly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: const Color(0xFF1F6FEB).withOpacity(0.15),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_outlined, size: 14, color: Color(0xFF1F6FEB)),
                  SizedBox(width: 6),
                  Text(
                    'View only — editing is disabled',
                    style: TextStyle(color: Color(0xFF1F6FEB), fontSize: 12),
                  ),
                ],
              ),
            ),

          // Language selector bar
          Container(
            color: const Color(0xFF161B22),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Language:',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  _LanguageChip(
                    label: 'Python',
                    selected: _selectedLanguage == 'Python',
                    onTap: () => _changeLanguage('Python'),
                  ),
                  const SizedBox(width: 8),
                  _LanguageChip(
                    label: 'JavaScript',
                    selected: _selectedLanguage == 'JavaScript',
                    onTap: () => _changeLanguage('JavaScript'),
                  ),
                  const SizedBox(width: 8),
                  _LanguageChip(
                    label: 'C++',
                    selected: _selectedLanguage == 'C++',
                    onTap: () => _changeLanguage('C++'),
                  ),
                  const SizedBox(width: 8),
                  _LanguageChip(
                    label: 'Java',
                    selected: _selectedLanguage == 'Java',
                    onTap: () => _changeLanguage('Java'),
                  ),
                  const SizedBox(width: 8),
                  _LanguageChip(
                    label: 'Dart',
                    selected: _selectedLanguage == 'Dart',
                    onTap: () => _changeLanguage('Dart'),
                  ),
                ],
              ),
            ),
          ),

          // Code editor
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(styles: atomOneDarkTheme),
              child: SingleChildScrollView(
                child: CodeField(
                  controller: _codeController,
                  readOnly: _isReadOnly,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  lineNumberStyle: const LineNumberStyle(
                    width: 48,
                    margin: 8,
                    textStyle: TextStyle(
                      color: Color(0xFF636E7B),
                      fontSize: 13,
                    ),
                    background: Color(0xFF161B22),
                  ),
                  background: const Color(0xFF0D1117),
                  minLines: 30,
                ),
              ),
            ),
          ),

          // Output panel
          Container(
            height: 120,
            color: const Color(0xFF161B22),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Output',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _selectedLanguage.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Run your code to see output here...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF238636)
              : const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF238636)
                : const Color(0xFF30363D),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
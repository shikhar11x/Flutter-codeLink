import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/dart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/services/pad_service.dart';
import '../../../core/services/execution_service.dart';
import '../../collaborator/models/collaborator_model.dart';
import '../../collaborator/widgets/avatar_group.dart';
import '../../collaborator/widgets/collab_panel.dart';
import '../../collaborator/widgets/permission_badge.dart';
import '../../share/widgets/share_drawer.dart';
import '../../settings/widgets/settings_sheet.dart';
import '../widgets/language_bar.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/readonly_banner.dart';
import '../widgets/pad_title.dart';

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
  bool _isLoading = true;
  bool _isConnected = false;
  String _output = '';
  bool _isRunning = false;
  String _padTitle = '';
  late CodeController _codeController;
  DateTime? _lastEmit;

  List<Collaborator> _collaborators = [
    Collaborator(id: '1', name: 'You', color: const Color(0xFFD0D8FF)),
  ];

  @override
  void initState() {
    super.initState();
    _padTitle = widget.padSlug;
    _codeController = CodeController(text: '', language: java);
    _initPad();
  }

  Future<void> _initPad() async {
    var pad = await PadService.getPad(widget.padSlug);
    pad ??= await PadService.createPad(slug: widget.padSlug);

    if (pad != null && mounted) {
      setState(() {
        _codeController = CodeController(
          text: pad!['content'] ?? '',
          language: java,
        );
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }

    _connectSocket();
  }

  void _connectSocket() {
    SocketService.connect();
    SocketService.joinPad(widget.padSlug, 'You', '#D0D8FF');

    SocketService.onPadInit((data) {
      if (mounted) {
        setState(() {
          _codeController = CodeController(
            text: data['content'] ?? '',
            language: java,
          );
        });
      }
    });

    SocketService.onCodeUpdate((content) {
      if (mounted && content != _codeController.text) {
        final selection = _codeController.selection;
        _codeController.text = content;
        _codeController.selection = selection;
      }
    });

    SocketService.onUsersUpdate((users) {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _collaborators = users.map<Collaborator>((u) {
            Color color = const Color(0xFFD0D8FF);
            try {
              final hex = (u['color'] as String)
                  .replaceFirst('#', '')
                  .padLeft(6, '0');
              color = Color(int.parse('FF$hex', radix: 16));
            } catch (_) {}
            return Collaborator(
              id: u['id'].toString(),
              name: u['name'].toString(),
              color: color,
            );
          }).toList();
        });
      }
    });

    SocketService.onLanguageUpdate((lang) {
      if (mounted) _changeLanguage(lang, emit: false);
    });
  }

  void _onCodeChanged(String content) {
    final now = DateTime.now();
    _lastEmit = now;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_lastEmit == now) {
        SocketService.sendCodeChange(widget.padSlug, content);
      }
    });
  }

  void _changeLanguage(String lang, {bool emit = true}) {
    setState(() {
      _selectedLanguage = lang;
      _codeController = CodeController(
        text: _codeController.text,
        language: switch (lang) {
          'Java'       => java,
          'Python'     => python,
          'JavaScript' => javascript,
          'C++'        => cpp,
          _            => dart,
        },
      );
    });
    if (emit) SocketService.sendLanguageChange(widget.padSlug, lang);
  }

  Future<void> _runCode() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _output = '';
    });

    final result = await ExecutionService.execute(
      language: _selectedLanguage,
      code: _codeController.text,
    );

    if (mounted) {
      setState(() {
        _isRunning = false;
        _output = result.output;
      });
    }
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
  void dispose() {
    SocketService.offAll();
    _codeController.dispose();
    super.dispose();
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
              child: PadTitle(
                padSlug: widget.padSlug,
                onTitleChanged: (title) {
                  setState(() => _padTitle = title);
                },
              ),
            ),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _isConnected
                    ? const Color(0xFF00FF94)
                    : Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isConnected
                            ? const Color(0xFF00FF94)
                            : Colors.orange)
                        .withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
              color: _isRunning
                  ? AppColors.surface
                  : AppColors.whiteDim,
              borderRadius: BorderRadius.circular(8),
              border: _isRunning
                  ? Border.all(color: AppColors.border)
                  : null,
              boxShadow: _isRunning
                  ? null
                  : [
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
                onTap: _runCode,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      if (_isRunning)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 16,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isRunning ? 'Running' : 'Run',
                        style: TextStyle(
                          color: _isRunning
                              ? AppColors.textSecondary
                              : Colors.black,
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00FF94),
                strokeWidth: 2,
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    if (_isReadOnly) const ReadOnlyBanner(),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CodeEditorWidget(
                              controller: _codeController,
                              readOnly: _isReadOnly,
                              onChanged: _onCodeChanged,
                            ),
                          ),
                          CollabPanel(
                            collaborators: _collaborators,
                            output: _output,
                            isRunning: _isRunning,
                            language: _selectedLanguage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 64),
                  ],
                ),
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
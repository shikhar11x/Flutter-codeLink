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
import '../../../core/services/auth_service.dart';
import '../../../core/utils/slug_generator.dart';
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
  bool _showLineNumbers = true;
  bool _wordWrap = false;
  int _fontSize = 14;
  bool _isReadOnly = false;
  bool _isLoading = true;
  bool _isConnected = false;
  String _output = '';
  bool _isRunning = false;
  String _padTitle = '';
  String _fileName = 'Main.java';
  bool _isLocked = false;
  String _lockedBy = '';
  bool _bottomPanelVisible = false;
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

    final userName = AuthService.isLoggedIn
        ? (AuthService.user?['name'] ?? 'Anonymous')
        : 'Anonymous';

    SocketService.joinPad(widget.padSlug, userName, '#D0D8FF');

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

    SocketService.onPadLocked((locked, lockedBy) {
      if (mounted) {
        setState(() {
          _isLocked = locked;
          _lockedBy = lockedBy;
          if (_currentRole != UserRole.owner) {
            _isReadOnly = locked;
          }
        });
      }
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

  void _handleLockToggle() {
    final userName = AuthService.isLoggedIn
        ? (AuthService.user?['name'] ?? 'Owner')
        : 'Owner';
    final newLocked = !_isReadOnly;
    setState(() {
      _isReadOnly = newLocked;
      _isLocked = newLocked;
      _lockedBy = userName;
    });
    SocketService.sendPadLock(widget.padSlug, newLocked, userName);
  }

  void _openNewPad() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(padSlug: SlugGenerator.generate()),
      ),
    );
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
        initialAnyoneCanEdit: !_isReadOnly,
        initialLineNumbers: _showLineNumbers,
        initialWordWrap: _wordWrap,
        initialFontSize: _fontSize,
        onReadOnlyChanged: (val) => setState(() => _isReadOnly = val),
        onLineNumbersChanged: (val) => setState(() => _showLineNumbers = val),
        onWordWrapChanged: (val) => setState(() => _wordWrap = val),
        onFontSizeChanged: (val) => setState(() => _fontSize = val),
        onPadDeleted: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
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
    final isMobile = MediaQuery.of(context).size.width < 600;

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
            if (!isMobile) ...[
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
              const SizedBox(width: 8),
            ],
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
            const SizedBox(width: 4),
          ],
        ),
        actions: [
          // ── Desktop actions ──
          if (!isMobile) ...[
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
            ),
            IconButton(
              onPressed: _showSettingsSheet,
              icon: const Icon(
                Icons.tune_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // ── Mobile: Permission badge + 3 dot menu ──
          if (isMobile) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: PermissionBadge(role: _currentRole),
            ),
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: _showShareDrawer,
                  child: const Row(
                    children: [
                      Icon(Icons.share_rounded,
                          size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 10),
                      Text('Share',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: _showSettingsSheet,
                  child: const Row(
                    children: [
                      Icon(Icons.tune_rounded,
                          size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 10),
                      Text('Settings',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: _openNewPad,
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded,
                          size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 10),
                      Text('New Pad',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // ── Run button — both ──
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: _isRunning ? AppColors.surface : AppColors.whiteDim,
              borderRadius: BorderRadius.circular(8),
              border: _isRunning ? Border.all(color: AppColors.border) : null,
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
                    horizontal: 12,
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
          : isMobile
              ? _buildMobileLayout()
              : _buildDesktopLayout(),
    );
  }

  // ── Desktop Layout ──
  Widget _buildDesktopLayout() {
    return Stack(
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
                      fontSize: _fontSize,
                      showLineNumbers: _showLineNumbers,
                      wordWrap: _wordWrap,
                    ),
                  ),
                  CollabPanel(
                    collaborators: _collaborators,
                    output: _output,
                    isRunning: _isRunning,
                    language: _selectedLanguage,
                    isOwner: _currentRole == UserRole.owner,
                    isReadOnly: _isReadOnly,
                    isLocked: _isLocked,
                    lockedBy: _lockedBy,
                    onLockToggle: _currentRole == UserRole.owner
                        ? _handleLockToggle
                        : null,
                    onNewPad: _openNewPad,
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
              onFileNameChanged: (name) => setState(() => _fileName = name),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile Layout ──
  Widget _buildMobileLayout() {
    return Column(
      children: [
        if (_isReadOnly) const ReadOnlyBanner(),

        // Code editor
        Expanded(
          child: CodeEditorWidget(
            controller: _codeController,
            readOnly: _isReadOnly,
            onChanged: _onCodeChanged,
            fontSize: _fontSize,
            showLineNumbers: false,
            wordWrap: true,
          ),
        ),

        // Bottom panel — animated
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: _bottomPanelVisible ? 260 : 0,
          child: _bottomPanelVisible
              ? _MobilePanelTabs(
                  collaborators: _collaborators,
                  output: _output,
                  isRunning: _isRunning,
                  language: _selectedLanguage,
                  isOwner: _currentRole == UserRole.owner,
                  isReadOnly: _isReadOnly,
                  isLocked: _isLocked,
                  lockedBy: _lockedBy,
                  onLockToggle: _currentRole == UserRole.owner
                      ? _handleLockToggle
                      : null,
                  onNewPad: _openNewPad,
                )
              : const SizedBox.shrink(),
        ),

        // Language bar + toggle arrow
        Container(
          color: AppColors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle arrow
              GestureDetector(
                onTap: () => setState(
                  () => _bottomPanelVisible = !_bottomPanelVisible,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  child: Icon(
                    _bottomPanelVisible
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),

              // Language bar
              LanguageBar(
                selected: _selectedLanguage,
                onChanged: _changeLanguage,
                onFileNameChanged: (name) => setState(() => _fileName = name),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mobile Panel Tabs ──
class _MobilePanelTabs extends StatefulWidget {
  final List<Collaborator> collaborators;
  final String output;
  final bool isRunning;
  final String language;
  final bool isOwner;
  final bool isReadOnly;
  final bool isLocked;
  final String lockedBy;
  final VoidCallback? onLockToggle;
  final VoidCallback? onNewPad;

  const _MobilePanelTabs({
    required this.collaborators,
    required this.output,
    required this.isRunning,
    required this.language,
    required this.isOwner,
    required this.isReadOnly,
    required this.isLocked,
    required this.lockedBy,
    this.onLockToggle,
    this.onNewPad,
  });

  @override
  State<_MobilePanelTabs> createState() => _MobilePanelTabsState();
}

class _MobilePanelTabsState extends State<_MobilePanelTabs> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          // Tab bar
          Row(
            children: [
              _TabBtn(
                label: 'Output',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
                dot: widget.isRunning,
              ),
              _TabBtn(
                label: 'Collaborators',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
                dot: true,
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onNewPad,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, color: Colors.black, size: 12),
                      SizedBox(width: 3),
                      Text(
                        'New Pad',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Container(height: 1, color: AppColors.border),

          // Content
          Expanded(
            child: _tab == 0
                ? _OutputTab(
                    output: widget.output,
                    isRunning: widget.isRunning,
                  )
                : _CollabTab(
                    collaborators: widget.collaborators,
                    isOwner: widget.isOwner,
                    isReadOnly: widget.isReadOnly,
                    isLocked: widget.isLocked,
                    lockedBy: widget.lockedBy,
                    onLockToggle: widget.onLockToggle,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dot;

  const _TabBtn({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.white : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (dot)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(right: 5),
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutputTab extends StatelessWidget {
  final String output;
  final bool isRunning;

  const _OutputTab({
    required this.output,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Text(
        output.isEmpty
            ? (isRunning ? 'Running...' : 'Run your code to see output here...')
            : output,
        style: TextStyle(
          color: output.isEmpty ? AppColors.textMuted : AppColors.green,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CollabTab extends StatelessWidget {
  final List<Collaborator> collaborators;
  final bool isOwner;
  final bool isReadOnly;
  final bool isLocked;
  final String lockedBy;
  final VoidCallback? onLockToggle;

  const _CollabTab({
    required this.collaborators,
    required this.isOwner,
    required this.isReadOnly,
    required this.isLocked,
    required this.lockedBy,
    this.onLockToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...collaborators.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        c.initials,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    c.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isLocked && !isOwner)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 13,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Locked by $lockedBy',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          if (isOwner)
            GestureDetector(
              onTap: onLockToggle,
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isReadOnly
                      ? Colors.orange.withValues(alpha: 0.08)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isReadOnly
                        ? Colors.orange.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isReadOnly
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      size: 13,
                      color: isReadOnly ? Colors.orange : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isReadOnly ? 'Locked' : 'Lock pad',
                      style: TextStyle(
                        color: isReadOnly
                            ? Colors.orange
                            : AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/recent_pads_service.dart';
import '../../auth/widgets/auth_sheet.dart';
import '../widgets/open_pad_dialog.dart';
import '../widgets/recent_pads_list.dart';
import '../widgets/pad_input_box.dart';
import '../../editor/screens/editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final String _fullText = 'codelink new';
  String _typedText = '';
  int _typeIndex = 0;
  Timer? _typeTimer;

  late AnimationController _glitchCtrl;
  String _glitchTitle = 'CodeLink';
  final _glitchChars = '!<>-_\\/[]{}—=+*^?#@%\$&';
  Timer? _glitchTimer;

  bool _showCreating = false;
  bool _showReady = false;
  bool _showCopied = false;
  bool _showPrompt2 = false;
  bool _showButtons = false;

  late AnimationController _matrixCtrl;

  List<Map<String, dynamic>> _recentPads = [];

  void _openEditor(BuildContext context, String slug) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(padSlug: slug)),
    );
  }

  Future<void> _loadRecentPads() async {
    if (AuthService.isLoggedIn) {
      final pads = await RecentPadsService.getRecentPads();
      if (mounted) setState(() => _recentPads = pads);
    }
  }

  void _handleAuthTap() async {
    if (AuthService.isLoggedIn) {
      await AuthService.logout();
      if (mounted) setState(() => _recentPads = []);
    } else {
      final loggedIn = await AuthSheet.show(context);
      if (loggedIn == true) _loadRecentPads();
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _matrixCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _glitchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    Future.delayed(const Duration(milliseconds: 300), _startGlitch);
    Future.delayed(const Duration(milliseconds: 800), _startTypewriter);

    _loadRecentPads();
  }

  void _startGlitch() {
    if (!mounted) return;
    int count = 0;
    _glitchTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      count++;
      if (count > 10) {
        t.cancel();
        setState(() => _glitchTitle = 'CodeLink');
        return;
      }
      final rand = Random();
      final glitched = 'CodeLink'.split('').map((c) {
        return rand.nextDouble() < 0.4
            ? _glitchChars[rand.nextInt(_glitchChars.length)]
            : c;
      }).join();
      setState(() => _glitchTitle = glitched);
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _startGlitch();
    });
  }

  void _startTypewriter() {
    if (!mounted) return;
    _typeTimer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_typeIndex >= _fullText.length) {
        t.cancel();
        _scheduleLines();
        return;
      }
      setState(() {
        _typedText += _fullText[_typeIndex];
        _typeIndex++;
      });
    });
  }

  void _scheduleLines() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showCreating = true);
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showReady = true);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showCopied = true);
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showPrompt2 = true);
    });
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (mounted) setState(() => _showButtons = true);
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _glitchTimer?.cancel();
    _glitchCtrl.dispose();
    _matrixCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── Matrix rain background ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _matrixCtrl,
              builder: (_, __) =>
                  CustomPaint(painter: _MatrixPainter(_matrixCtrl.value)),
            ),
          ),

          // ── Login button top-right ──
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: _handleAuthTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AuthService.isLoggedIn
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AuthService.isLoggedIn
                            ? (AuthService.user?['name'] ?? 'Logout')
                            : 'Login',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Glitch title
                    Text(
                      _glitchTitle,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: AppColors.white.withOpacity(0.3),
                            blurRadius: 20,
                          ),
                          Shadow(
                            color: AppColors.white.withOpacity(0.1),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Real-time collaborative code editor',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ── Terminal Card ──
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.white.withOpacity(0.03),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                _TrafficDot(color: const Color(0xFFFF5F57)),
                                const SizedBox(width: 6),
                                _TrafficDot(color: const Color(0xFFFFBD2E)),
                                const SizedBox(width: 6),
                                _TrafficDot(color: const Color(0xFF28C840)),
                                const SizedBox(width: 12),
                                Text(
                                  'codelink — zsh',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const Spacer(),
                                _PulseDot(color: AppColors.white),
                                const SizedBox(width: 5),
                                Text(
                                  '3,421 online',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Terminal body
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Typewriter line
                                Row(
                                  children: [
                                    Text(
                                      '~ \$ ',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    Text(
                                      _typedText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    if (_typeIndex < _fullText.length)
                                      _BlinkingCursor(color: AppColors.white),
                                  ],
                                ),

                                if (_showCreating) ...[
                                  const SizedBox(height: 6),
                                  _FadeInLine(
                                    text: 'Creating pad...',
                                    color: AppColors.textMuted,
                                  ),
                                ],
                                if (_showReady) ...[
                                  const SizedBox(height: 4),
                                  _FadeInLine(
                                    text: '✓ swift-river-4829 ready',
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                                if (_showCopied) ...[
                                  const SizedBox(height: 4),
                                  _FadeInLine(
                                    text: '✓ Sharing link copied',
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                                if (_showPrompt2) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '~ \$ ',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      _BlinkingCursor(color: AppColors.white),
                                    ],
                                  ),
                                ],

                                if (_showButtons) ...[
                                  const SizedBox(height: 20),
                                  PadInputBox(
                                    onSubmit: (slug) =>
                                        _openEditor(context, slug),
                                  ),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: TextButton(
                                      onPressed: () async {
                                        final slug =
                                            await OpenPadDialog.show(context);
                                        if (slug != null && context.mounted) {
                                          _openEditor(context, slug);
                                        }
                                      },
                                      child: Text(
                                        'or open an existing pad',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_recentPads.isNotEmpty)
                      RecentPadsList(pads: _recentPads),

                    const SizedBox(height: 40),

                    Text(
                      'No account needed — just share the link',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Matrix Rain Painter ──
class _MatrixPainter extends CustomPainter {
  final double progress;
  static final _rand = Random(42);
  static final List<double> _xPositions = List.generate(30, (i) => i * 13.0);
  static final List<double> _speeds = List.generate(
    30,
    (_) => 0.3 + _rand.nextDouble() * 0.7,
  );
  static final List<String> _chars = List.generate(
    30,
    (_) => String.fromCharCode(0x30A0 + _rand.nextInt(96)),
  );

  _MatrixPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _xPositions.length; i++) {
      final y =
          ((progress * _speeds[i] * size.height * 2) + i * 37.0) % size.height;
      final opacity = (0.03 + (i % 5) * 0.01).clamp(0.0, 0.06);
      final tp = TextPainter(
        text: TextSpan(
          text: _chars[i],
          style: TextStyle(
            color: AppColors.white.withOpacity(opacity),
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_xPositions[i], y));
    }
  }

  @override
  bool shouldRepaint(_MatrixPainter old) => old.progress != progress;
}

// ── Helper Widgets ──

class _TrafficDot extends StatelessWidget {
  final Color color;
  const _TrafficDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_anim.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_anim.value * 0.4),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  const _BlinkingCursor({required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value,
        child: Container(width: 8, height: 14, color: widget.color),
      ),
    );
  }
}

class _FadeInLine extends StatefulWidget {
  final String text;
  final Color color;
  const _FadeInLine({required this.text, required this.color});

  @override
  State<_FadeInLine> createState() => _FadeInLineState();
}

class _FadeInLineState extends State<_FadeInLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.color,
          fontSize: 13,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ),
    );
  }
}
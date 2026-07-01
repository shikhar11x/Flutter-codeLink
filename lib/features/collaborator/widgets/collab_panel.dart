import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/collaborator_model.dart';

class CollabPanel extends StatefulWidget {
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

  const CollabPanel({
    super.key,
    required this.collaborators,
    this.output = '',
    this.isRunning = false,
    required this.language,
    this.isOwner = false,
    this.isReadOnly = false,
    this.isLocked = false,
    this.lockedBy = '',
    this.onLockToggle,
    this.onNewPad,
  });

  @override
  State<CollabPanel> createState() => _CollabPanelState();
}

class _CollabPanelState extends State<CollabPanel> {
  double _width = 180;
  static const double _minWidth = 120;
  static const double _maxWidth = 380;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Drag handle ──
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _width = (_width - details.delta.dx).clamp(_minWidth, _maxWidth);
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: SizedBox(
              width: 8,
              child: Center(
                child: Container(
                  width: 2,
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ),

        // ── Panel ──
        SizedBox(
          width: _width,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                left: BorderSide(
                  color: AppColors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(dot: true, dotActive: true, label: 'Live'),

                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                  child: Text(
                    'COLLABORATORS',
                    style: AppTheme.label.copyWith(
                      fontSize: 9,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                ...widget.collaborators.asMap().entries.map(
                  (e) => _CollabRow(
                    collaborator: e.value,
                    index: e.key,
                  ),
                ),

                // ── Lock status ──
                if (widget.isLocked && !widget.isOwner) ...[
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 10,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Locked by ${widget.lockedBy}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Owner lock button ──
                if (widget.isOwner) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: widget.onLockToggle,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isReadOnly
                            ? Colors.orange.withValues(alpha: 0.08)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.isReadOnly
                              ? Colors.orange.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isReadOnly
                                ? Icons.lock_rounded
                                : Icons.lock_open_rounded,
                            size: 10,
                            color: widget.isReadOnly
                                ? Colors.orange
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.isReadOnly ? 'Locked' : 'Lock pad',
                            style: TextStyle(
                              color: widget.isReadOnly
                                  ? Colors.orange
                                  : AppColors.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    height: 1,
                    color: AppColors.white.withValues(alpha: 0.04),
                  ),
                ),

                _SectionHeader(
                  dot: true,
                  dotActive: widget.isRunning,
                  label: widget.isRunning ? 'Running...' : 'Output',
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                    child: widget.output.isEmpty
                        ? Text(
                            'Run your code\nto see output.',
                            style: AppTheme.label.copyWith(
                              fontSize: 10,
                              height: 1.6,
                              letterSpacing: 0,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _OutputLine(text: 'running...', muted: true),
                              _OutputLine(
                                text: widget.output,
                                success: true,
                              ),
                              _OutputLine(text: 'exit code 0', muted: true),
                              const SizedBox(height: 8),
                              _ResultCard(language: widget.language),
                            ],
                          ),
                  ),
                ),

                // ── New Pad button ──
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: widget.onNewPad,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteDim,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.white.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Colors.black,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'New Pad',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final bool dot;
  final bool dotActive;
  final String label;

  const _SectionHeader({
    required this.dot,
    required this.dotActive,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.white.withValues(alpha: 0.04),
          ),
        ),
      ),
      child: Row(
        children: [
          if (dot)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotActive ? AppColors.green : AppColors.textMuted,
                shape: BoxShape.circle,
                boxShadow: dotActive
                    ? [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.6),
                          blurRadius: 5,
                        ),
                      ]
                    : null,
              ),
            ),
          if (dot) const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: AppTheme.label.copyWith(fontSize: 9, letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }
}

class _CollabRow extends StatefulWidget {
  final Collaborator collaborator;
  final int index;

  const _CollabRow({
    required this.collaborator,
    required this.index,
  });

  @override
  State<_CollabRow> createState() => _CollabRowState();
}

class _CollabRowState extends State<_CollabRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(
      Duration(milliseconds: widget.index * 300),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: widget.collaborator.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.collaborator.initials,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              widget.collaborator.name,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Opacity(
              opacity: _anim.value,
              child: Container(
                width: 2,
                height: 11,
                decoration: BoxDecoration(
                  color: widget.collaborator.color,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: widget.collaborator.color.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
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

class _OutputLine extends StatelessWidget {
  final String text;
  final bool muted;
  final bool success;

  const _OutputLine({
    required this.text,
    this.muted = false,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '› ',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: AppColors.white.withValues(alpha: 0.15),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              height: 1.7,
              color: success
                  ? AppColors.green
                  : muted
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String language;
  const _ResultCard({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.05),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _ResRow(
            label: 'Status',
            value: '✓ OK',
            valueColor: AppColors.green,
          ),
          const SizedBox(height: 3),
          _ResRow(label: 'Time', value: '0.08s'),
          const SizedBox(height: 3),
          _ResRow(label: 'Memory', value: '8.4 MB'),
        ],
      ),
    );
  }
}

class _ResRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ResRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textSecondary,
            fontSize: 9,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
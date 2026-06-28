import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../collaborator/widgets/permission_badge.dart';
import 'settings_tile.dart';

class SettingsSheet extends StatefulWidget {
  final UserRole currentRole;
  final String padSlug;
  final Function(bool) onReadOnlyChanged;

  const SettingsSheet({
    super.key,
    required this.currentRole,
    required this.padSlug,
    required this.onReadOnlyChanged,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _anyoneCanEdit = true;
  bool _showLineNumbers = true;
  bool _wordWrap = false;
  int _fontSize = 14;

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.green,
      activeTrackColor: AppColors.green.withValues(alpha: 0.2),
      inactiveThumbColor: AppColors.textMuted,
      inactiveTrackColor: AppColors.border,
    );
  }

  Widget _buildFontSizeControl() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SmallBtn(
          icon: Icons.remove,
          onTap: () {
            if (_fontSize > 10) setState(() => _fontSize--);
          },
        ),
        const SizedBox(width: 10),
        Text(
          '$_fontSize',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
        const SizedBox(width: 10),
        _SmallBtn(
          icon: Icons.add,
          onTap: () {
            if (_fontSize < 24) setState(() => _fontSize++);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              const Text('Settings', style: AppTheme.heading2),
              const Spacer(),
              PermissionBadge(role: widget.currentRole),
            ],
          ),
          const SizedBox(height: 24),

          // Access control — owner only
          if (widget.currentRole == UserRole.owner) ...[
            Text(
              'ACCESS CONTROL',
              style: AppTheme.label.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            SettingsTile(
              icon: Icons.people_outline_rounded,
              title: 'Anyone can edit',
              subtitle: 'Anyone with the link can make changes',
              trailing: _buildSwitch(_anyoneCanEdit, (val) {
                setState(() => _anyoneCanEdit = val);
                widget.onReadOnlyChanged(!val);
              }),
            ),
            const SizedBox(height: 20),
          ],

          Text(
            'EDITOR',
            style: AppTheme.label.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          SettingsTile(
            icon: Icons.format_list_numbered_rounded,
            title: 'Line numbers',
            subtitle: 'Show line numbers in editor',
            trailing: _buildSwitch(
              _showLineNumbers,
              (val) => setState(() => _showLineNumbers = val),
            ),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.wrap_text_rounded,
            title: 'Word wrap',
            subtitle: 'Wrap long lines automatically',
            trailing: _buildSwitch(
              _wordWrap,
              (val) => setState(() => _wordWrap = val),
            ),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.format_size_rounded,
            title: 'Font size',
            subtitle: 'Current: ${_fontSize}px',
            trailing: _buildFontSizeControl(),
          ),

          if (widget.currentRole == UserRole.owner) ...[
            const SizedBox(height: 20),
            Text(
              'DANGER ZONE',
              style: AppTheme.label.copyWith(color: Colors.red[400]),
            ),
            const SizedBox(height: 10),
            SettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete this pad',
              subtitle: 'This action cannot be undone',
              iconColor: Colors.red[400],
              trailing: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

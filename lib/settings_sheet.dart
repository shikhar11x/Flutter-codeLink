import 'package:flutter/material.dart';
import 'permission_badge.dart';

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
  String _fontSize = '14';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title row
          Row(
            children: [
              const Text(
                'Pad Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              PermissionBadge(role: widget.currentRole),
            ],
          ),
          const SizedBox(height: 24),

          // Section: Access Control (only owner can see)
          if (widget.currentRole == UserRole.owner) ...[
            _SectionHeader(title: 'Access Control'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.people_outline,
              title: 'Anyone can edit',
              subtitle: 'Anyone with the link can make changes',
              trailing: Switch(
                value: _anyoneCanEdit,
                onChanged: (val) {
                  setState(() => _anyoneCanEdit = val);
                  widget.onReadOnlyChanged(!val);
                },
                activeColor: const Color(0xFF238636),
              ),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Pad visibility',
              subtitle: _anyoneCanEdit ? 'Public — anyone can edit' : 'View only — no editing allowed',
              trailing: Icon(
                _anyoneCanEdit ? Icons.public : Icons.lock,
                color: _anyoneCanEdit ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Section: Editor Preferences
          _SectionHeader(title: 'Editor Preferences'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.format_list_numbered,
            title: 'Line numbers',
            subtitle: 'Show line numbers in editor',
            trailing: Switch(
              value: _showLineNumbers,
              onChanged: (val) => setState(() => _showLineNumbers = val),
              activeColor: const Color(0xFF238636),
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.wrap_text,
            title: 'Word wrap',
            subtitle: 'Wrap long lines automatically',
            trailing: Switch(
              value: _wordWrap,
              onChanged: (val) => setState(() => _wordWrap = val),
              activeColor: const Color(0xFF238636),
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.format_size,
            title: 'Font size',
            subtitle: 'Current: ${_fontSize}px',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconBtn(
                  icon: Icons.remove,
                  onTap: () {
                    final size = int.parse(_fontSize);
                    if (size > 10) setState(() => _fontSize = '${size - 1}');
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  _fontSize,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 8),
                _IconBtn(
                  icon: Icons.add,
                  onTap: () {
                    final size = int.parse(_fontSize);
                    if (size < 24) setState(() => _fontSize = '${size + 1}');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section: Danger Zone (only owner)
          if (widget.currentRole == UserRole.owner) ...[
            _SectionHeader(title: 'Danger Zone', color: Colors.red[400]!),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Delete this pad',
              subtitle: 'This action cannot be undone',
              iconColor: Colors.red[400],
              trailing: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // delete logic backend ke baad
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red[400]),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const _SectionHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: color ?? Colors.grey[500],
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Icon(icon, size: 14, color: Colors.white70),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // NOTE: these toggles are local-only in this starter. Wire them to a
  // `users/{uid}` Firestore field (and read it back on load) to persist them.
  bool _twoFactor = true;
  bool _saveLogin = true;
  bool _dataSaver = false;
  bool _autoplay = true;
  bool _push = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _SectionLabel('ACCOUNT'),
          _Toggle(label: 'Two-factor login', sub: 'Extra security for your account', value: _twoFactor, onChanged: (v) => setState(() => _twoFactor = v)),
          _Toggle(label: 'Save login on this device', value: _saveLogin, onChanged: (v) => setState(() => _saveLogin = v)),
          _SectionLabel('PLAYBACK'),
          _Toggle(label: 'Data saver mode', sub: 'Lower quality on mobile data', value: _dataSaver, onChanged: (v) => setState(() => _dataSaver = v)),
          _Toggle(label: 'Autoplay next episode', value: _autoplay, onChanged: (v) => setState(() => _autoplay = v)),
          _SectionLabel('PREFERENCES'),
          _Toggle(label: 'Push notifications', value: _push, onChanged: (v) => setState(() => _push = v)),
          _Toggle(label: 'Dark mode', value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
          _SectionLabel('ABOUT'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline_rounded, color: AppColors.ocean),
            title: Text('Help and support', style: AppText.inter(size: 13, weight: FontWeight.w600, color: AppColors.navy)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.shield_outlined, color: AppColors.ocean),
            title: Text('Privacy policy', style: AppText.inter(size: 13, weight: FontWeight.w600, color: AppColors.navy)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout_rounded, color: AppColors.ember),
            title: Text('Log out', style: AppText.inter(size: 13, weight: FontWeight.w600, color: AppColors.ember)),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
          const SizedBox(height: 18),
          Center(child: Text('RF TV app · version 1.0.0', style: AppText.inter(size: 10.5, color: AppColors.slateLight))),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 4),
        child: Text(text, style: AppText.sora(size: 12, color: AppColors.slateLight, letterSpacing: 1)),
      );
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, this.sub, required this.value, required this.onChanged});
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.inter(size: 13, weight: FontWeight.w600, color: AppColors.navy)),
                if (sub != null) Text(sub!, style: AppText.inter(size: 11, color: AppColors.slate)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.sky),
        ],
      ),
    );
  }
}

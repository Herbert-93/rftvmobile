import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final initials = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!.trim().split(' ').map((s) => s[0]).take(2).join().toUpperCase()
        : (user?.email?.substring(0, 2).toUpperCase() ?? '??');

    return SafeArea(
      bottom: false,
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 40),
            decoration: const BoxDecoration(gradient: AppColors.brandGradient),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profile', style: AppText.sora(size: 15.5, color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                  ),
                  child: Center(child: Text(initials, style: AppText.sora(size: 22, color: Colors.white))),
                ),
                const SizedBox(height: 10),
                Text(user?.displayName ?? 'RF TV member', style: AppText.sora(size: 15.5, color: Colors.white)),
                const SizedBox(height: 2),
                Text(user?.email ?? '', style: AppText.inter(size: 11.5, color: Colors.white.withOpacity(0.75))),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -26),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
              ),
              child: const Row(
                children: [
                  Expanded(child: _StatBlock(n: '0h', l: 'Watch time')),
                  _Divider(),
                  Expanded(child: _StatBlock(n: '0', l: 'Favorites')),
                  _Divider(),
                  Expanded(child: _StatBlock(n: 'UGX 0', l: 'Donated')),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _MenuRow(icon: Icons.person_outline_rounded, label: 'Edit profile'),
                _MenuRow(icon: Icons.bookmark_border_rounded, label: 'My favorites'),
                _MenuRow(icon: Icons.download_outlined, label: 'Downloads'),
                _MenuRow(icon: Icons.history_rounded, label: 'Donation history'),
                _MenuRow(icon: Icons.notifications_none_rounded, label: 'Notifications'),
                _MenuRow(icon: Icons.help_outline_rounded, label: 'Help and support'),
                _MenuRow(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  danger: true,
                  onTap: () => authService.signOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.n, required this.l});
  final String n;
  final String l;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(n, style: AppText.sora(size: 16)),
        const SizedBox(height: 2),
        Text(l, style: AppText.inter(size: 10.5, color: AppColors.slate)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: AppColors.line);
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.danger = false, this.onTap});
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: danger ? const Color(0xFFFDECE8) : AppColors.cream2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: danger ? AppColors.ember : AppColors.ocean),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(label, style: AppText.inter(size: 13, weight: FontWeight.w600, color: danger ? AppColors.ember : AppColors.navy))),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.slateLight),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(color: AppColors.ember, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('LIVE', style: AppText.sora(size: small ? 9 : 10.5, color: Colors.white, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

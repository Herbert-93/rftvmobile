import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RfBottomNav extends StatelessWidget {
  const RfBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.live_tv_rounded, label: 'Live TV'),
    (icon: Icons.radio_rounded, label: 'Radio'),
    (icon: Icons.favorite_rounded, label: 'Donate'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_items.length, (i) {
            final active = i == currentIndex;
            final item = _items[i];
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 22, color: active ? AppColors.sky : AppColors.slateLight),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: AppText.inter(
                        size: 10.5,
                        weight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? AppColors.navy : AppColors.slateLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

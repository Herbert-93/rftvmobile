import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/program.dart';
import '../screens/program_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/program_category.dart';

/// A tappable card for a single program. Used in the home screen's weekly
/// lineup, category screens, and the Live TV "Highlights" shelves. Always
/// opens ProgramDetailScreen, which itself hands off to the video player
/// when content is linked.
class ProgramCard extends StatelessWidget {
  const ProgramCard({super.key, required this.program, this.showTime = false});

  final Program program;
  final bool showTime;

  String _durationLabel(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return m > 0 ? '${h}h ${m}m' : '${h}h';
    return '$m min';
  }

  @override
  Widget build(BuildContext context) {
    final durationLabel = _durationLabel(program.durationMinutes);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => ProgramDetailScreen(program: program)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppColors.brandGradient),
              child: Icon(categoryIcon(program.category),
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTime)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(DateFormat.jm().format(program.startTime),
                          style: AppText.inter(
                              size: 11,
                              weight: FontWeight.w700,
                              color: AppColors.sky)),
                    ),
                  Text(program.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sora(size: 13)),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if ((program.category ?? '').isNotEmpty) program.category,
                      if (durationLabel.isNotEmpty) durationLabel
                    ].join(' • '),
                    style: AppText.inter(size: 11, color: AppColors.slate),
                  ),
                ],
              ),
            ),
            if (program.hasVideo)
              const Padding(
                padding: EdgeInsets.only(left: 6, top: 2),
                child: Icon(Icons.play_circle_fill_rounded,
                    color: AppColors.sky, size: 26),
              ),
          ],
        ),
      ),
    );
  }
}

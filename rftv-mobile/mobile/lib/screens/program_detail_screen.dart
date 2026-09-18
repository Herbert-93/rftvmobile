import 'package:flutter/material.dart';
import '../models/program.dart';
import '../theme/app_theme.dart';
import '../utils/program_category.dart';
import 'program_player_screen.dart';

/// Shown when the user taps a program from the home screen's weekly lineup,
/// a category screen, or Live TV's highlights. Plays the linked video when
/// one exists, otherwise shows the details with a disabled "coming soon"
/// state instead of a dead tap.
class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({super.key, required this.program});

  final Program program;

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
    final hasThumbnail = (program.thumbnailUrl ?? '').trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                      decoration: const BoxDecoration(
                          gradient: AppColors.brandGradient)),
                  if (hasThumbnail)
                    Image.network(
                      program.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.35),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(categoryIcon(program.category),
                          color: AppColors.navy, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(program.title, style: AppText.sora(size: 19)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if ((program.category ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sky.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(program.category!,
                                style: AppText.inter(
                                    size: 11.5,
                                    weight: FontWeight.w700,
                                    color: AppColors.sky)),
                          ),
                        if (durationLabel.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.line.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(durationLabel,
                                style: AppText.inter(
                                    size: 11.5,
                                    weight: FontWeight.w600,
                                    color: AppColors.slate)),
                          ),
                      ],
                    ),
                    if ((program.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(program.description!,
                          style: AppText.inter(
                              size: 13.5, color: AppColors.slate)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: program.hasVideo
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => ProgramPlayerScreen(
                                          program: program)),
                                )
                            : null,
                        icon: Icon(program.hasVideo
                            ? Icons.play_arrow_rounded
                            : Icons.schedule_rounded),
                        label: Text(program.hasVideo
                            ? 'Watch now'
                            : 'Video coming soon'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sky,
                          disabledBackgroundColor: AppColors.line,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

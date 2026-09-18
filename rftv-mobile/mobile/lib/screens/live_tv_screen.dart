import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/program.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/program_category.dart';
import '../widgets/live_badge.dart';
import '../widgets/program_card.dart';
import 'program_player_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  final _api = ApiService();
  late Future<List<Program>> _programsFuture;

  @override
  void initState() {
    super.initState();
    _programsFuture = _api.getPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: AppColors.navy,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColors.navy2, AppColors.ocean]),
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.pause_rounded, color: Colors.white),
                ),
                const Positioned(top: 18, left: 18, child: LiveBadge()),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Program>>(
              future: _programsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final programs = snapshot.data ?? [];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [
                    Text('Up next', style: AppText.sora(size: 15)),
                    const SizedBox(height: 10),
                    ...programs.map(
                      (p) => GestureDetector(
                        onTap: p.hasVideo
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ProgramPlayerScreen(program: p)),
                                )
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(DateFormat.jm().format(p.startTime),
                                    style: AppText.inter(
                                        size: 11.5,
                                        weight: FontWeight.w700,
                                        color: AppColors.sky)),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.title,
                                        style: AppText.inter(
                                            size: 12.5,
                                            weight: FontWeight.w600,
                                            color: AppColors.navy)),
                                    if (p.durationMinutes != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text('${p.durationMinutes} min',
                                            style: AppText.inter(
                                                size: 11,
                                                color: AppColors.slate)),
                                      ),
                                  ],
                                ),
                              ),
                              if (p.hasVideo)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.sky.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.play_arrow_rounded,
                                          size: 14, color: AppColors.sky),
                                      const SizedBox(width: 2),
                                      Text('Watch',
                                          style: AppText.inter(
                                              size: 10.5,
                                              weight: FontWeight.w700,
                                              color: AppColors.sky)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (programs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('No programs scheduled yet.',
                            style: AppText.inter(color: AppColors.slate)),
                      ),

                    // ---------------- Highlights ----------------
                    ...(() {
                      final shelves = <Widget>[];
                      for (final category in kProgramCategories) {
                        final items = programs
                            .where((p) => p.category == category)
                            .toList()
                          ..sort((a, b) => a.startTime.compareTo(b.startTime));
                        if (items.isEmpty) continue;
                        shelves.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 18, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(category, style: AppText.sora(size: 15)),
                                Icon(categoryIcon(category),
                                    size: 16, color: AppColors.slate),
                              ],
                            ),
                          ),
                        );
                        shelves.add(
                          SizedBox(
                            height: 78,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length > 8 ? 8 : items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) => SizedBox(
                                width: 230,
                                child: ProgramCard(program: items[i]),
                              ),
                            ),
                          ),
                        );
                      }
                      return shelves;
                    })(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

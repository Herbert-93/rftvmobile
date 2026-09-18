import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../models/program.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/program_category.dart';
import '../widgets/live_badge.dart';
import '../widgets/program_card.dart';
import '../widgets/section_title.dart';
import 'category_screen.dart';
import 'live_tv_screen.dart';

const List<String> _kWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
];

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _api = ApiService();
  late Future<List<Channel>> _channelsFuture;
  late Future<List<Program>> _programsFuture;

  // DateTime.weekday: Monday = 1 ... Sunday = 7. Default to today.
  int _selectedWeekday = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    _channelsFuture = _api.getChannels();
    _programsFuture = _api.getPrograms();
  }

  Future<void> _refresh() async {
    setState(() {
      _channelsFuture = _api.getChannels();
      _programsFuture = _api.getPrograms();
    });
    await Future.wait([_channelsFuture, _programsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Channel>>(
          future: _channelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorState(
                  message: snapshot.error.toString(), onRetry: _refresh);
            }
            final channels = snapshot.data ?? [];
            final liveChannel = channels.where((c) => c.isLive).isNotEmpty
                ? channels.firstWhere((c) => c.isLive)
                : null;

            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppText.sora(size: 16),
                          children: [
                            const TextSpan(text: 'RF'),
                            TextSpan(
                                text: 'tv',
                                style: AppText.sora(
                                    size: 16, color: AppColors.sky)),
                          ],
                        ),
                      ),
                      const Icon(Icons.notifications_none_rounded,
                          color: AppColors.navy),
                    ],
                  ),
                ),
                if (liveChannel != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const LiveTvScreen())),
                      child: Container(
                        height: 170,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: AppColors.brandGradient),
                        child: Stack(
                          children: [
                            const Positioned(
                                top: 12, left: 12, child: LiveBadge()),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 14,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${liveChannel.name}: Family Hour',
                                      style: AppText.sora(
                                          size: 17, color: Colors.white)),
                                  const SizedBox(height: 3),
                                  Text('Streaming now',
                                      style: AppText.inter(
                                          size: 11.5,
                                          color:
                                              Colors.white.withOpacity(0.8))),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: AppColors.navy),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ---------------- Categories ----------------
                const SectionTitle(title: 'Browse by category'),
                SizedBox(
                  height: 86,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: kProgramCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final category = kProgramCategories[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    CategoryScreen(category: category))),
                        child: Container(
                          width: 76,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: AppColors.brandGradient),
                                child: Icon(categoryIcon(category),
                                    color: Colors.white, size: 18),
                              ),
                              const SizedBox(height: 6),
                              Text(category,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.inter(
                                      size: 10.5,
                                      weight: FontWeight.w600,
                                      color: AppColors.navy)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ---------------- Weekly lineup ----------------
                const SectionTitle(title: 'This week'),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _kWeekdays.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final weekdayValue = i + 1; // Monday = 1 ... Sunday = 7
                      final isSelected = weekdayValue == _selectedWeekday;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedWeekday = weekdayValue),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.navy : Colors.white,
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.navy
                                    : AppColors.line),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _kWeekdays[i].substring(0, 3),
                            style: AppText.inter(
                              size: 12,
                              weight: FontWeight.w700,
                              color:
                                  isSelected ? Colors.white : AppColors.slate,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FutureBuilder<List<Program>>(
                    future: _programsFuture,
                    builder: (context, psnap) {
                      if (psnap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (psnap.hasError) {
                        return Text("Couldn't load the schedule.",
                            style: AppText.inter(
                                size: 12.5, color: AppColors.slate));
                      }
                      final dayPrograms = (psnap.data ?? [])
                          .where((p) => p.startTime.weekday == _selectedWeekday)
                          .toList()
                        ..sort((a, b) => a.startTime.compareTo(b.startTime));

                      if (dayPrograms.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Nothing scheduled for ${_kWeekdays[_selectedWeekday - 1]} yet.',
                            style: AppText.inter(
                                size: 12.5, color: AppColors.slate),
                          ),
                        );
                      }

                      return Column(
                        children: dayPrograms
                            .map((p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child:
                                      ProgramCard(program: p, showTime: true),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),

                const SectionTitle(title: 'Channels'),
                ...channels.map(
                  (ch) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: AppColors.brandGradient),
                            child: const Icon(Icons.tv_rounded,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ch.name, style: AppText.sora(size: 13)),
                                Text(ch.category,
                                    style: AppText.inter(
                                        size: 11.5, color: AppColors.slate)),
                              ],
                            ),
                          ),
                          if (ch.isLive) const LiveBadge(small: true),
                        ],
                      ),
                    ),
                  ),
                ),
                if (channels.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                        child: Text(
                            'No channels yet. Add some from the admin panel.',
                            style: AppText.inter(color: AppColors.slate))),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Couldn't load channels", style: AppText.sora(size: 15)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: AppText.inter(size: 12, color: AppColors.slate)),
            const SizedBox(height: 14),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

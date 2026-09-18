import 'package:flutter/material.dart';
import '../models/program.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/program_card.dart';

/// Shows every program an admin has tagged with [category], fetched live
/// from the backend — reached by tapping a category on the Home screen.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.category});

  final String category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _api = ApiService();
  late Future<List<Program>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getPrograms();
  }

  Future<void> _refresh() async {
    setState(() => _future = _api.getPrograms());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        title: Text(widget.category, style: AppText.sora(size: 16)),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Program>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  Center(
                    child: Text("Couldn't load ${widget.category} programs.",
                        textAlign: TextAlign.center,
                        style: AppText.inter(color: AppColors.slate)),
                  ),
                ],
              );
            }

            final programs = (snapshot.data ?? [])
                .where((p) =>
                    (p.category ?? '').toLowerCase() ==
                    widget.category.toLowerCase())
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

            if (programs.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  Center(
                    child: Text(
                      'No ${widget.category} programs yet. Check back soon.',
                      textAlign: TextAlign.center,
                      style: AppText.inter(color: AppColors.slate),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: programs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  ProgramCard(program: programs[i], showTime: true),
            );
          },
        ),
      ),
    );
  }
}

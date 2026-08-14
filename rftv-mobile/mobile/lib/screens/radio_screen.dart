import 'package:flutter/material.dart';
import '../models/radio_status.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final _api = ApiService();
  late Future<RadioStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _api.getRadioStatus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<RadioStatus>(
        future: _statusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final status = snapshot.data;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(gradient: AppColors.flameGradient, shape: BoxShape.circle),
                    child: const Icon(Icons.radio_rounded, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 26),
                  Text(status?.headline ?? 'RF Radio is coming soon', textAlign: TextAlign.center, style: AppText.sora(size: 22)),
                  const SizedBox(height: 8),
                  Text(status?.message ?? '', textAlign: TextAlign.center, style: AppText.inter(size: 13, color: AppColors.slate)),
                  if ((status?.launchLabel ?? '').isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(color: AppColors.cream2, borderRadius: BorderRadius.circular(99)),
                      child: Text(status!.launchLabel, style: AppText.inter(size: 11.5, weight: FontWeight.w700, color: AppColors.ocean)),
                    ),
                  ],
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: status?.isLive == true ? 'Listen now' : 'Notify me at launch',
                    icon: status?.isLive == true ? Icons.play_arrow_rounded : Icons.notifications_active_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(status?.isLive == true ? 'Playback not wired up in this starter yet.' : "We'll notify you when radio launches.")),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

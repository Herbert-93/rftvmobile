import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/program.dart';
import '../theme/app_theme.dart';

/// Plays the video an admin has linked to a program (a movie or a recorded
/// TV program) and shows its title, duration and description underneath.
class ProgramPlayerScreen extends StatefulWidget {
  const ProgramPlayerScreen({super.key, required this.program});

  final Program program;

  @override
  State<ProgramPlayerScreen> createState() => _ProgramPlayerScreenState();
}

class _ProgramPlayerScreenState extends State<ProgramPlayerScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final url = widget.program.videoUrl;
    if (url == null || url.trim().isEmpty) {
      _error = 'No video is linked to this program yet.';
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _error = 'This video link looks invalid.';
      return;
    }
    _controller = VideoPlayerController.networkUrl(uri)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller!.play();
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _error =
            'Could not load this video. Check the link and try again.');
      });
    _controller!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return m > 0 ? '${h}h ${m}m' : '${h}h';
    return '$m min';
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;
    final durationLabel = _formatDuration(program.durationMinutes);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _ready ? _controller!.value.aspectRatio : 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black),
                  if (_ready && _controller != null)
                    GestureDetector(
                      onTap: () => setState(() {
                        _controller!.value.isPlaying
                            ? _controller!.pause()
                            : _controller!.play();
                      }),
                      child: VideoPlayer(_controller!),
                    )
                  else if (_error == null)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  if (_ready &&
                      _controller != null &&
                      !_controller!.value.isPlaying)
                    const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 64),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            if (_ready && _controller != null)
              VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                colors: const VideoProgressColors(
                  playedColor: AppColors.sky,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.cream,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(program.title, style: AppText.sora(size: 18)),
                      if (durationLabel.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(durationLabel,
                            style: AppText.inter(
                                size: 12.5,
                                weight: FontWeight.w600,
                                color: AppColors.slate)),
                      ],
                      if ((program.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(program.description!,
                            style: AppText.inter(
                                size: 13.5, color: AppColors.slate)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

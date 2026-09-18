class Program {
  final String id;
  final String channelId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int? durationMinutes;
  final String? category;

  Program({
    required this.id,
    required this.channelId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    this.durationMinutes,
    this.category,
  });

  /// True when an admin has linked actual playable content (a movie or a
  /// recorded program) to this schedule entry.
  bool get hasVideo => videoUrl != null && videoUrl!.trim().isNotEmpty;

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json['id'] as String,
        channelId: json['channelId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        startTime: DateTime.tryParse(json['startTime'] as String? ?? '') ??
            DateTime.now(),
        endTime: DateTime.tryParse(json['endTime'] as String? ?? '') ??
            DateTime.now(),
        description: json['description'] as String?,
        videoUrl: json['videoUrl'] as String?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
        category: json['category'] as String?,
      );
}

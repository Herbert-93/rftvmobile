class Program {
  final String id;
  final String channelId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  Program({
    required this.id,
    required this.channelId,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json['id'] as String,
        channelId: json['channelId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        startTime: DateTime.tryParse(json['startTime'] as String? ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(json['endTime'] as String? ?? '') ?? DateTime.now(),
      );
}

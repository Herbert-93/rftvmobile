class Channel {
  final String id;
  final String name;
  final String category;
  final bool isLive;
  final int order;
  final int viewerCount;

  Channel({
    required this.id,
    required this.name,
    required this.category,
    required this.isLive,
    required this.order,
    this.viewerCount = 0,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? 'All',
        isLive: json['isLive'] as bool? ?? false,
        order: (json['order'] as num?)?.toInt() ?? 0,
        viewerCount: (json['viewerCount'] as num?)?.toInt() ?? 0,
      );
}

class RadioStatus {
  final bool isLive;
  final String headline;
  final String message;
  final String launchLabel;
  final String? streamUrl;

  RadioStatus({
    required this.isLive,
    required this.headline,
    required this.message,
    required this.launchLabel,
    this.streamUrl,
  });

  factory RadioStatus.fromJson(Map<String, dynamic> json) => RadioStatus(
        isLive: json['isLive'] as bool? ?? false,
        headline: json['headline'] as String? ?? 'RF Radio is coming soon',
        message: json['message'] as String? ?? '',
        launchLabel: json['launchLabel'] as String? ?? 'Launching soon',
        streamUrl: json['streamUrl'] as String?,
      );
}

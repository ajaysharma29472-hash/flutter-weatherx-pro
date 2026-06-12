enum AlertSeverity { extreme, severe, moderate, minor, unknown }

class WeatherAlert {
  final String senderName;
  final String event;
  final DateTime start;
  final DateTime end;
  final String description;
  final List<String> tags;

  WeatherAlert({
    required this.senderName,
    required this.event,
    required this.start,
    required this.end,
    required this.description,
    required this.tags,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      senderName: json['sender_name'] as String? ?? 'Weather Service',
      event: json['event'] as String? ?? 'Weather Alert',
      start: DateTime.fromMillisecondsSinceEpoch(
          ((json['start'] as num?) ?? 0).toInt() * 1000),
      end: DateTime.fromMillisecondsSinceEpoch(
          ((json['end'] as num?) ?? 0).toInt() * 1000),
      description: json['description'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  AlertSeverity get severity {
    final lower = event.toLowerCase();
    if (lower.contains('extreme') ||
        lower.contains('tornado') ||
        lower.contains('hurricane') ||
        lower.contains('typhoon')) return AlertSeverity.extreme;
    if (lower.contains('severe') ||
        lower.contains('warning') ||
        lower.contains('blizzard') ||
        lower.contains('ice storm')) return AlertSeverity.severe;
    if (lower.contains('watch') ||
        lower.contains('advisory') ||
        lower.contains('wind') ||
        lower.contains('flood')) return AlertSeverity.moderate;
    if (lower.contains('statement') || lower.contains('special')) {
      return AlertSeverity.minor;
    }
    return AlertSeverity.unknown;
  }

  bool get isActive => DateTime.now().isBefore(end);

  bool get isExpiringSoon =>
      isActive && end.difference(DateTime.now()).inHours < 3;

  Duration get timeRemaining => end.difference(DateTime.now());

  String get timeRemainingLabel {
    final diff = timeRemaining;
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return 'Ends in ${diff.inDays}d ${diff.inHours.remainder(24)}h';
    if (diff.inHours > 0) return 'Ends in ${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    return 'Ends in ${diff.inMinutes}m';
  }

  String get shortDescription {
    final lines = description.split('\n').where((l) => l.trim().isNotEmpty);
    final first = lines.isNotEmpty ? lines.first.trim() : description;
    return first.length > 120 ? '${first.substring(0, 117)}...' : first;
  }
}

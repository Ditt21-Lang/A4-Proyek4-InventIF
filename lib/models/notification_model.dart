class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> m) {
    return NotificationModel(
      id: m['id'] ?? '',
      title: m['title'] ?? '',
      body: m['body'] ?? '',
      timestamp:
          DateTime.parse(m['timestamp'] ?? DateTime.now().toIso8601String()),
      read: m['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }
}

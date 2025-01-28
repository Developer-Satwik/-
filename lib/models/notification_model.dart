class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.read,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> data) {
    return NotificationItem(
      id: data['id'],
      userId: data['user_id'],
      title: data['title'],
      message: data['message'],
      createdAt: DateTime.parse(data['created_at']),
      read: data['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'read': read,
    };
  }
} 
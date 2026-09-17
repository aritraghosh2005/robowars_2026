class NotificationItem {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory NotificationItem.fromFirestore(Map<String, dynamic> data, String documentId) {
    return NotificationItem(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
}

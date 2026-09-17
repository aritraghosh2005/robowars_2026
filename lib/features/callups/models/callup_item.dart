class CallupItem {
  final String id;
  final String teamId;
  final String teamName;
  final String message;
  final bool isActive;
  final DateTime timestamp;

  const CallupItem({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.message,
    this.isActive = true,
    required this.timestamp,
  });

  factory CallupItem.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CallupItem(
      id: documentId,
      teamId: data['teamId'] ?? '',
      teamName: data['teamName'] ?? 'Unknown Team',
      message: data['message'] ?? '',
      isActive: data['isActive'] ?? true,
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
}

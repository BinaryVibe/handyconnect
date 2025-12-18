class Message {
  final String id;
  final String serviceId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.serviceId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
  return Message(
    id: json['id']?.toString() ?? '',
    serviceId: json['service_id']?.toString() ?? '',
    senderId: json['sender_id']?.toString() ?? '',
    content: json['content'] ?? '',
    createdAt: DateTime.parse(json['created_at']),
    isRead: json['is_read'] ?? false,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
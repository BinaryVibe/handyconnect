import '../models/message.dart';
import '../models/service.dart';

class ChatData {
  final Service service;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String otherUserRole; // 'Worker' or 'Customer'
  final Message? lastMessage;
  final int unreadCount;

  ChatData({
    required this.service,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.otherUserRole,
    this.lastMessage,
    this.unreadCount = 0,
  });
}

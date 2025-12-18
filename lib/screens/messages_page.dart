import 'package:flutter/material.dart';
import 'package:handyconnect/providers/chat_provider.dart';
import 'package:handyconnect/providers/user_provider.dart';

import '../models/message.dart';
import '../models/service.dart';
import '../utils/chat_data.dart';

// Color Constants
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color listTileColor = Color(0xFFad8042);
const Color secondaryTextColor = Color(0xFFBFAB67);
const Color tagsBgColor = Color(0xFFBFC882);
const Color professionColor = Color(0xFFede0d4);
const Color nameColor = Color(0xFFe6ccb2);

// ============================================================================
// CHATS LIST SCREEN
// ============================================================================

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatHandler _chatHandler = ChatHandler();
  final UserHandler _userHandler = UserHandler();
  
  List<ChatData> _chats = [];
  bool _isChatsLoading = true;
  
  // Future variable to hold the role check
  late final Future<bool> _roleFuture;
  
  String? get _currentUserId => _userHandler.userId;

  @override
  void initState() {
    super.initState();
    // Initialize the future once
    _roleFuture = _loadIsCustomer();
    _loadChats();
  }

  Future<bool> _loadIsCustomer() async {
    final role = await _userHandler.getValue('role');
    return role == 'customer';
  }

  Future<void> _loadChats() async {
    setState(() => _isChatsLoading = true);
    try {
      final chats = await _chatHandler.fetchChats();
      if (mounted) {
        setState(() {
          _chats = chats;
          _isChatsLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        setState(() => _isChatsLoading = false);
        _showError('Failed to load chats');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(color: kPrimaryColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Messages",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _loadChats,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          // Use FutureBuilder here to determine the role
          child: FutureBuilder<bool>(
            future: _roleFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading user profile',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              // Default to false if data is null, or handle as you prefer
              final isCustomer = snapshot.data ?? false;

              // Now handle the chat list loading state
              if (_isChatsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_chats.isEmpty) {
                return _buildEmptyState(isCustomer);
              }

              return _buildChatsList(isCustomer);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isCustomer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              isCustomer
                  ? 'Messages will appear when workers accept your requests'
                  : 'Messages will appear when you accept service requests',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList(bool isCustomer) {
    return RefreshIndicator(
      onRefresh: _loadChats,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                return ChatCard(
                  chatData: _chats[index],
                  currentUserId: _currentUserId!,
                  isCustomer: isCustomer,
                  onTap: () => _openChat(_chats[index], isCustomer),
                );
              },
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chats.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width ~/ 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) {
              return ChatCard(
                chatData: _chats[index],
                currentUserId: _currentUserId!,
                isCustomer: isCustomer,
                onTap: () => _openChat(_chats[index], isCustomer),
              );
            },
          );
        },
      ),
    );
  }

  void _openChat(ChatData chatData, bool isCustomer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          service: chatData.service,
          currentUserId: _currentUserId!,
          otherUserName: chatData.otherUserName,
          otherUserAvatar: chatData.otherUserAvatar,
          isCustomer: isCustomer,
        ),
      ),
    ).then((_) => _loadChats()); // Refresh when returning
  }
}

// ============================================================================
// CHAT CARD WIDGET
// ============================================================================

class ChatCard extends StatelessWidget {
  final ChatData chatData;
  final String currentUserId;
  final bool isCustomer;
  final VoidCallback onTap;

  const ChatCard({
    super.key,
    required this.chatData,
    required this.currentUserId,
    required this.isCustomer,
    required this.onTap,
  });

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: listTileColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: chatData.otherUserAvatar != null
                            ? NetworkImage(chatData.otherUserAvatar!)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: chatData.otherUserAvatar == null
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                      if (chatData.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: listTileColor,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                chatData.unreadCount > 9
                                    ? '9+'
                                    : '${chatData.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatData.otherUserName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: nameColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chatData.otherUserRole,
                          style: const TextStyle(
                            fontSize: 12,
                            color: professionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (chatData.lastMessage != null)
                    Text(
                      _getTimeAgo(chatData.lastMessage!.createdAt),
                      style: const TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tagsBgColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.work, size: 14, color: Color(0xFF3E4C22)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        chatData.service.serviceTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3E4C22),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (chatData.lastMessage != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (chatData.lastMessage!.senderId == currentUserId)
                      Icon(
                        chatData.lastMessage!.isRead
                            ? Icons.done_all
                            : Icons.done,
                        size: 16,
                        color: chatData.lastMessage!.isRead
                            ? Colors.blue
                            : secondaryTextColor,
                      ),
                    if (chatData.lastMessage!.senderId == currentUserId)
                      const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        chatData.lastMessage!.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              chatData.unreadCount > 0 &&
                                      chatData.lastMessage!.senderId !=
                                          currentUserId
                                  ? nameColor
                                  : professionColor,
                          fontWeight:
                              chatData.unreadCount > 0 &&
                                      chatData.lastMessage!.senderId !=
                                          currentUserId
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CHAT DETAIL SCREEN (Individual Chat)
// ============================================================================

class ChatDetailScreen extends StatefulWidget {
  final Service service;
  final String currentUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final bool isCustomer;

  const ChatDetailScreen({
    super.key,
    required this.service,
    required this.currentUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.isCustomer,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHandler _chatHandler = ChatHandler();
  final UserHandler _userHandler = UserHandler();
  String? get _currentUserId => _userHandler.userId;

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _chatHandler.fetchMessages(widget.service.id);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
        _markMessagesAsRead();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load messages');
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    await _chatHandler.markMessagesAsRead(widget.service.id, _currentUserId!);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      final message = await _chatHandler.sendMessage(
        serviceId: widget.service.id,
        senderId: _currentUserId!,
        content: content,
      );

      if (mounted) {
        setState(() {
          _messages.add(message);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _showError('Failed to send message');
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildServiceInfoBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kPrimaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.otherUserAvatar != null
                ? NetworkImage(widget.otherUserAvatar!)
                : null,
            backgroundColor: kFieldColor,
            child: widget.otherUserAvatar == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.isCustomer ? 'Worker' : 'Customer',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: _showServiceDetails,
        ),
      ],
    );
  }

  Widget _buildServiceInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: listTileColor.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: listTileColor.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.work, color: kPrimaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.service.serviceTitle,
              style: const TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == _currentUserId;
        final showTimestamp = _shouldShowTimestamp(index);

        return Column(
          children: [
            if (showTimestamp) _buildTimestampDivider(message.createdAt),
            _buildMessageBubble(message, isMe),
          ],
        );
      },
    );
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;

    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];

    final difference = currentMessage.createdAt.difference(
      previousMessage.createdAt,
    );
    return difference.inMinutes > 30;
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: secondaryTextColor.withOpacity(0.3))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatTimestamp(timestamp),
              style: const TextStyle(fontSize: 12, color: secondaryTextColor),
            ),
          ),
          Expanded(child: Divider(color: secondaryTextColor.withOpacity(0.3))),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (messageDate == yesterday) {
      return 'Yesterday ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : kPrimaryColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead
                        ? Colors.blue[200]
                        : Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kFieldColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: secondaryTextColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: kPrimaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.work, 'Title', widget.service.serviceTitle),
            if (widget.service.description != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.description,
                'Description',
                widget.service.description!,
              ),
            ],
            if (widget.service.location != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.location_on,
                'Location',
                widget.service.location!,
              ),
            ],
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_today,
              'Created',
              '${widget.service.createdAt.day}/${widget.service.createdAt.month}/${widget.service.createdAt.year}',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: listTileColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: kPrimaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
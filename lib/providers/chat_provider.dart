import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../models/service.dart';
import '../utils/chat_data.dart';

class ChatHandler {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ChatData>> fetchChats() async {
    final currentUserId = _supabase.auth.currentUser!.id;

    // FIX 1: Change .select('id, worker_id, customer_id') to .select('*')
    // Your Service.fromJson likely needs 'service_title', 'created_at', etc.
    // fetching only IDs caused those fields to be null.
    final servicesResponse = await _supabase
        .from('services')
        .select('*')
        .or('worker_id.eq.$currentUserId,customer_id.eq.$currentUserId');

    final List<ChatData> chats = [];

    for (final serviceJson in servicesResponse) {
      // This should now work because serviceJson contains all fields
      final service = Service.fromJson(serviceJson);

      final isWorker = service.workerId == currentUserId;

      // Ensure we handle potential nulls if your model allows null IDs
      // (casting as String just to be safe for the next query)
      final otherUserId =
          (isWorker ? service.customerId : service.workerId) as String;

      // 2. Fetch last message
      final lastMessageJson = await _supabase
          .from('messages')
          .select()
          .eq('service_id', service.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final lastMessage = lastMessageJson != null
          ? Message.fromJson(lastMessageJson)
          : null;

      // 3. Count unread messages
      final unreadResponse = await _supabase
          .from('messages')
          .select('id')
          .eq('service_id', service.id)
          .eq('is_read', false)
          .neq('sender_id', currentUserId);

      final unreadCount = unreadResponse.length;

      // 4. Fetch other user profile
      final otherUserJson = await _supabase
          .from('profiles')
          .select('first_name, last_name, avatar_url, role')
          .eq('id', otherUserId)
          .single();

      final name = '${otherUserJson['first_name'] ?? ''} ${otherUserJson['last_name'] ?? ''}';
      final role = otherUserJson['role'] == 'worker' ? 'Worker' : 'Customer';

      chats.add(
        ChatData(
          service: service,
          otherUserId: otherUserId,
          // FIX 2: Use null-coalescing operators (??)
          // In case the name or role is null in the database profile
          otherUserName: name,
          otherUserAvatar:
              otherUserJson['avatar_url'], // Null is usually allowed here
          otherUserRole: role,
          lastMessage: lastMessage,
          unreadCount: unreadCount,
        ),
      );
    }

    return chats;
  }

  /// Fetch all messages for a service (ordered oldest → newest)
  Future<List<Message>> fetchMessages(String serviceId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('service_id', serviceId)
        .order('created_at', ascending: true);

    return response.map<Message>((json) => Message.fromJson(json)).toList();
  }

  /// Mark all messages (sent by others) as read
  Future<void> markMessagesAsRead(
    String serviceId,
    String currentUserId,
  ) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('service_id', serviceId)
        .neq('sender_id', currentUserId)
        .eq('is_read', false);
  }

  /// Send a message and return the created message
  Future<Message> sendMessage({
    required String serviceId,
    required String senderId,
    required String content,
  }) async {
    final response = await _supabase
        .from('messages')
        .insert({
          'service_id': serviceId,
          'sender_id': senderId,
          'content': content,
        })
        .select()
        .single();

    return Message.fromJson(response);
  }
}

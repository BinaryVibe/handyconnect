import 'package:supabase_flutter/supabase_flutter.dart';

class UserSupabaseService {
  final supabase = Supabase.instance.client;
  late final userId = supabase.auth.currentUser?.id;

  Future<void> setUserRole(String role) async {
    try {
      print(userId);
      await supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', userId as String);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> setAvatarUrl(String avatarUrl) async {
    try {
      await supabase
          .from('profiles')
          .update({'avatar_url': avatarUrl})
          .eq('id', userId as String);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

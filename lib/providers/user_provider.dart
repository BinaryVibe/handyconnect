import 'package:supabase_flutter/supabase_flutter.dart';

class UserHandler {
  final supabase = Supabase.instance.client;
  late final userId = supabase.auth.currentUser?.id;

  Future<void> setUserRole(String role) async {
    try {
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

  Future<String> getValue(String field) async {
    try {
      final response = await supabase
          .from('profiles')
          .select(field)
          .eq('id', userId as String)
          .limit(1)
          .single();
      return response['role'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

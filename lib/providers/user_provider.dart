import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class UserHandler {
  final supabase = Supabase.instance.client;
  String? get userId => supabase.auth.currentUser?.id;

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
      return response[field];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> uploadAvatarAndSaveUrl({
    required Uint8List imageBytes,
    required String filePath,
    required String fileExt,
  }) async {
    final supabase = Supabase.instance.client;

    // Upload image to Supabase Storage
    await supabase.storage
        .from('avatars')
        .uploadBinary(
          filePath,
          imageBytes,
          fileOptions: FileOptions(upsert: true, contentType: 'image/$fileExt'),
        );

    // Get public URL
    final imageUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

    // Update profile with avatar URL
    await supabase
        .from('profiles')
        .update({'avatar_url': imageUrl})
        .eq('id', userId as String);

    return imageUrl;
  }
}

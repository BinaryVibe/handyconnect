import 'package:supabase_flutter/supabase_flutter.dart';


class CustomerHandler {
  final _supabase = Supabase.instance.client;
  String? get userId => _supabase.auth.currentUser?.id;

  Future<void> insertCustomer(Map<String, dynamic> customerData) async {
    customerData['id'] = userId;
    try {
      await _supabase.from('customers').insert(customerData);
    } catch (e) {
      throw Exception('Failed to insert Worker');
    }
  }

  Future<dynamic> getValue(String field) async {
    try {
      final response = await _supabase
          .from('customers')
          .select(field)
          .eq('id', userId as String)
          .limit(1)
          .single();
      return response[field];
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
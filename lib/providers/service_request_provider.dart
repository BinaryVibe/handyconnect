import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRequestHandler {
  final _supabase = Supabase.instance.client;

  // --- 1. Fetch Data (Updated to include Service Details) ---
  Future<ServiceRequestData> fetchRequestDetails(String serviceId) async {
    try {
      // A. Fetch Service Data
      final service = await _supabase
          .from('services')
          .select()
          .eq('id', serviceId)
          .single();

      // B. Fetch Customer Profile
      final customerId = service['customer_id'];
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', customerId)
          .single();

      // C. Fetch Service Details (For status, price, dates)
      // We use maybeSingle() because details might not exist if not accepted yet
      final details = await _supabase
          .from('service_details')
          .select()
          .eq('service_id', serviceId)
          .maybeSingle();

      return ServiceRequestData(
        serviceData: service,
        customerProfile: profile,
        serviceDetails: details, 
      );
    } catch (e) {
      throw Exception('Failed to load details: $e');
    }
  }

  // --- 2. Accept Service ---
  Future<void> acceptService({
    required String serviceId,
    required double price,
    required String estimatedEndDate,
  }) async {
    try {
      await _supabase
          .from('services')
          .update({'accepted_status': true})
          .eq('id', serviceId);

      // Check if details row exists before inserting/updating
      final existing = await _supabase
          .from('service_details')
          .select()
          .eq('service_id', serviceId)
          .maybeSingle();

      final data = {
        'price': price,
        'start_date': DateTime.now().toIso8601String(),
        'expected_end': estimatedEndDate,
      };

      if (existing != null) {
        await _supabase.from('service_details').update(data).eq('service_id', serviceId);
      } else {
        await _supabase.from('service_details').insert({
          ...data,
          'service_id': serviceId,
          'paid_status': false,
        });
      }
    } catch (e) {
      throw Exception('Failed to accept service: $e');
    }
  }

  // --- 3. Decline Service ---
  Future<void> declineService(String serviceId) async {
    try {
      await _supabase.from('services').delete().eq('id', serviceId);
    } catch (e) {
      throw Exception('Failed to decline service: $e');
    }
  }

  // --- 4. Update Job Progress (NEW) ---
  Future<void> updateJobProgress({
    required String serviceId,
    DateTime? newEstimatedEnd,
    bool markAsCompleted = false,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (newEstimatedEnd != null) {
        updates['expected_end'] = newEstimatedEnd.toIso8601String();
      }
      
      if (markAsCompleted) {
        updates['completed_date'] = DateTime.now().toIso8601String();
      }

      if (updates.isNotEmpty) {
        await _supabase
            .from('service_details')
            .update(updates)
            .eq('service_id', serviceId);
      }
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }
}

// --- Data Model ---
class ServiceRequestData {
  final Map<String, dynamic> serviceData;
  final Map<String, dynamic> customerProfile;
  final Map<String, dynamic>? serviceDetails; // Added this field

  ServiceRequestData({
    required this.serviceData,
    required this.customerProfile,
    this.serviceDetails,
  });
}
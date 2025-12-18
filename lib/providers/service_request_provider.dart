import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRequestHandler {
  final _supabase = Supabase.instance.client;

  // --- 1. Fetch Data ---
  Future<ServiceRequestData> fetchRequestDetails(String serviceId) async {
    try {
      // Fetch Service Data
      final service = await _supabase
          .from('services')
          .select()
          .eq('id', serviceId)
          .single();

      // Fetch Customer Profile using the customer_id from the service
      final customerId = service['customer_id'];
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', customerId)
          .single();

      return ServiceRequestData(
        serviceData: service,
        customerProfile: profile,
      );
    } catch (e) {
      throw Exception('Failed to load details: $e');
    }
  }

  // --- 2. Accept Service ---
  Future<void> acceptService({
    required String serviceId,
    required double price,
    required String estimatedEndDate, // Pass as ISO String
  }) async {
    try {
      // Update 'services' -> Accepted
      await _supabase
          .from('services')
          .update({'accepted_status': true})
          .eq('id', serviceId);

      // Update 'service_details' -> Add Price, Start Date, End Date
      await _supabase
          .from('service_details')
          .update({
            'price': price,
            'start_date': DateTime.now().toIso8601String(),
            'expected_end': estimatedEndDate,
          })
          .eq('service_id', serviceId);
    } catch (e) {
      throw Exception('Failed to accept service: $e');
    }
  }

  // --- 3. Decline Service ---
  Future<void> declineService(String serviceId) async {
    try {
      await _supabase
          .from('services')
          .delete()
          .eq('id', serviceId);
    } catch (e) {
      throw Exception('Failed to decline service: $e');
    }
  }
}

// --- Data Model Class ---
class ServiceRequestData {
  final Map<String, dynamic> serviceData;
  final Map<String, dynamic> customerProfile;

  ServiceRequestData({
    required this.serviceData,
    required this.customerProfile,
  });
}
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/service.dart';
import '../models/service_details.dart';
import '../utils/customer_with_service.dart';
import '../utils/service_with_worker.dart';

class CustomerServiceHandler {
  final _supabase = Supabase.instance.client;

  Future<List<ServiceWithWorker>> fetchCustomerServices(
    String customerId,
  ) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_details(*),
            workers:worker_id(
              profession,
              profile:profiles(
                first_name,
                last_name,
                avatar_url,
                phone_number
              )
            )
          ''')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      final result = (response).map((json) {
        final serviceDetailsData = json.remove('service_details');
        ServiceDetails serviceDetails = ServiceDetails.fromJson(
          serviceDetailsData,
        );
        final workerData = json.remove('workers');
        final String workerName =
            '${workerData['profile']['first_name'] ?? ''} ${workerData['profile']['last_name'] ?? ''}';
        final String workerPhone = workerData['profile']['phone_number'];
        final String workerAvatar = workerData['profile']['avatar_url'];

        final String workerProfession = workerData['profression'] ?? 'Unkown';
        Service service = Service.fromJson(json);
        return ServiceWithWorker(
          service: service,
          serviceDetails: serviceDetails,
          workerName: workerName,
          workerProfession: workerProfession,
          workerAvatar: workerAvatar,
          workerPhone: workerPhone,
        );
      }).toList();
      return result;
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }



Future<void> makePayment(String serviceId) async {
    try {
      await _supabase
          .from('service_details')
          .update({'paid_status': true})
          .eq('service_id', serviceId);
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  // --- 2. Submit Rating & Review ---
  Future<void> submitReview({
    required String serviceId,
    required String workerId,
    required double rating,
    required String comment,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('reviews').insert({
        'service_id': serviceId,
        'worker_id': workerId,
        'reviewer_id': userId, // Assuming your reviews table has this
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }
}

class WorkerServiceHandler {
  final _supabase = Supabase.instance.client;

  // Fetch all services for a worker with customer details
  Future<List<ServiceWithCustomer>> fetchWorkerServices(String workerId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            service_details(*),
            customers:customer_id(
              profile:profiles(
                  first_name,
                  last_name,
                  avatar_url,
                  phone_number
              )
            )
          ''')
          .eq('worker_id', workerId)
          .order('created_at', ascending: false);
      return (response as List).map((json) {
        final service = Service.fromJson(json);
        final serviceDetails = json['service_details'] != null
            ? ServiceDetails.fromJson(json['service_details'])
            : null;
        final customer = json['customers'];
      
        return ServiceWithCustomer(
          service: service,
          serviceDetails: serviceDetails,
          customerName: '${customer['profile']['first_name']} ${customer['profile']['last_name']}',
          customerAvatar: customer['profile']['avatar_url'],
          customerPhone: customer['profile']['phone_number'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  // Fetch services by status
  Future<List<ServiceWithCustomer>> fetchServicesByStatus(
    String workerId,
    String status,
  ) async {
    try {
      return List.empty();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }


Future<Map<String, dynamic>> fetchWorkerStats(String workerId) async {
    try {
      // 1. Fetch Completed Jobs & Earnings
      final servicesResponse = await _supabase
          .from('services')
          .select('service_details(price, paid_status)')
          .eq('worker_id', workerId)
          .eq('accepted_status', true);

      int completedJobs = 0;
      double totalEarnings = 0.0;

      final List<dynamic> serviceData = servicesResponse as List<dynamic>;
      for (var item in serviceData) {
        final details = item['service_details'];
        if (details != null && details['paid_status'] == true) {
          completedJobs++;
          totalEarnings += (details['price'] ?? 0).toDouble();
        }
      }

      // 2. Fetch Ratings
      final reviewsResponse = await _supabase
          .from('reviews')
          .select('rating')
          .eq('worker_id', workerId);

      double avgRating = 0.0;
      final List<dynamic> reviewsData = reviewsResponse as List<dynamic>;

      if (reviewsData.isNotEmpty) {
        double totalRating = 0.0;
        for (var item in reviewsData) {
          totalRating += (item['rating'] ?? 0).toDouble();
        }
        avgRating = totalRating / reviewsData.length;
      }

      return {
        'completedJobs': completedJobs,
        'totalEarnings': totalEarnings,
        'avgRating': avgRating,
      };
    } catch (e) {
      print('Error fetching stats: $e');
      return {'completedJobs': 0, 'totalEarnings': 0.0, 'avgRating': 0.0};
    }
  }

}

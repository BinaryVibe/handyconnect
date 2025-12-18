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

  // List<ServiceWithWorker> _getMockCustomerServices() {
  //   final now = DateTime.now();

  //   return [
  //     ServiceWithWorker(
  //       service: Service(
  //         id: 's1',
  //         workerId: 'w1',
  //         customerId: 'c123',
  //         serviceTitle: 'Kitchen Sink Repair',
  //         description:
  //             'Kitchen sink is leaking and needs urgent repair. Water is dripping constantly.',
  //         location: 'House #123, Street 5, Wah Cantt',
  //         acceptedStatus: false,
  //         createdAt: now.subtract(const Duration(hours: 2)),
  //         updatedAt: now.subtract(const Duration(hours: 2)),
  //       ),
  //       workerName: 'John Smith',
  //       workerAvatar: 'https://i.pravatar.cc/150?img=1',
  //       workerPhone: '+92-300-1234567',
  //       workerProfession: 'Plumber',
  //     ),
  //     ServiceWithWorker(
  //       service: Service(
  //         id: 's2',
  //         workerId: 'w2',
  //         customerId: 'c123',
  //         serviceTitle: 'Ceiling Fan Installation',
  //         description:
  //             'Need to install ceiling fan in bedroom and fix faulty switches.',
  //         location: 'House #123, Street 5, Wah Cantt',
  //         acceptedStatus: true,
  //         createdAt: now.subtract(const Duration(hours: 5)),
  //         updatedAt: now.subtract(const Duration(hours: 3)),
  //       ),
  //       serviceDetails: ServiceDetails(
  //         id: 'sd2',
  //         serviceId: 's2',
  //         price: 3000,
  //         priceUnit: 'PKR',
  //         bookingDate: now.subtract(const Duration(hours: 3)),
  //         startDate: null,
  //         expectedEnd: now.add(const Duration(days: 1)),
  //         completedDate: null,
  //         paidStatus: false,
  //         createdAt: now.subtract(const Duration(hours: 3)),
  //         updatedAt: now.subtract(const Duration(hours: 3)),
  //       ),
  //       workerName: 'Sarah Johnson',
  //       workerAvatar: 'https://i.pravatar.cc/150?img=2',
  //       workerPhone: '+92-301-9876543',
  //       workerProfession: 'Electrician',
  //     ),
  //     ServiceWithWorker(
  //       service: Service(
  //         id: 's3',
  //         workerId: 'w3',
  //         customerId: 'c123',
  //         serviceTitle: 'Bathroom Plumbing',
  //         description: 'Fix bathroom drainage and install new faucet.',
  //         location: 'House #123, Street 5, Wah Cantt',
  //         acceptedStatus: true,
  //         createdAt: now.subtract(const Duration(days: 1)),
  //         updatedAt: now.subtract(const Duration(hours: 1)),
  //       ),
  //       serviceDetails: ServiceDetails(
  //         id: 'sd3',
  //         serviceId: 's3',
  //         price: 2500,
  //         priceUnit: 'PKR',
  //         bookingDate: now.subtract(const Duration(hours: 6)),
  //         startDate: now.subtract(const Duration(hours: 2)),
  //         expectedEnd: now.add(const Duration(hours: 2)),
  //         completedDate: null,
  //         paidStatus: false,
  //         createdAt: now.subtract(const Duration(hours: 6)),
  //         updatedAt: now.subtract(const Duration(hours: 2)),
  //       ),
  //       workerName: 'Mike Davis',
  //       workerAvatar: 'https://i.pravatar.cc/150?img=3',
  //       workerPhone: '+92-333-4567890',
  //       workerProfession: 'Plumber',
  //     ),
  //     ServiceWithWorker(
  //       service: Service(
  //         id: 's4',
  //         workerId: 'w4',
  //         customerId: 'c123',
  //         serviceTitle: 'Wall Painting',
  //         description: 'Paint living room walls with premium quality paint.',
  //         location: 'House #123, Street 5, Wah Cantt',
  //         acceptedStatus: true,
  //         createdAt: now.subtract(const Duration(days: 3)),
  //         updatedAt: now.subtract(const Duration(days: 1)),
  //       ),
  //       serviceDetails: ServiceDetails(
  //         id: 'sd4',
  //         serviceId: 's4',
  //         price: 8000,
  //         priceUnit: 'PKR',
  //         bookingDate: now.subtract(const Duration(days: 2)),
  //         startDate: now.subtract(const Duration(days: 2)),
  //         expectedEnd: now.subtract(const Duration(days: 1)),
  //         completedDate: now.subtract(const Duration(days: 1)),
  //         paidStatus: true,
  //         createdAt: now.subtract(const Duration(days: 2)),
  //         updatedAt: now.subtract(const Duration(days: 1)),
  //       ),
  //       workerName: 'Emily Brown',
  //       workerAvatar: 'https://i.pravatar.cc/150?img=4',
  //       workerPhone: '+92-345-1122334',
  //       workerProfession: 'Painter',
  //     ),
  //   ];
  // }
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

  // Mock data generator
  // List<ServiceWithCustomer> _getMockServices() {
  //   final now = DateTime.now();

  //   return [
  //     ServiceWithCustomer(
  //       service: Service(
  //         id: 's1',
  //         workerId: 'w123',
  //         customerId: 'c1',
  //         serviceTitle: 'Kitchen Sink Repair',
  //         description:
  //             'Kitchen sink is leaking and needs urgent repair. Water is dripping constantly from the pipe connection.',
  //         location: 'House #123, Street 5, Wah Cantt',
  //         acceptedStatus: false,
  //         createdAt: now.subtract(const Duration(hours: 2)),
  //         updatedAt: now.subtract(const Duration(hours: 2)),
  //       ),
  //       customerName: 'Ahmed Khan',
  //       customerAvatar: 'https://i.pravatar.cc/150?img=11',
  //       customerPhone: '+92-300-1234567',
  //     ),
  //     ServiceWithCustomer(
  //       service: Service(
  //         id: 's2',
  //         workerId: 'w123',
  //         customerId: 'c2',
  //         serviceTitle: 'Ceiling Fan Installation',
  //         description:
  //             'Need to install ceiling fan in bedroom and fix two faulty switches in the living room.',
  //         location: 'Flat 4B, Al-Noor Plaza, Wah Cantt',
  //         acceptedStatus: false,
  //         createdAt: now.subtract(const Duration(hours: 5)),
  //         updatedAt: now.subtract(const Duration(hours: 5)),
  //       ),
  //       customerName: 'Fatima Ali',
  //       customerAvatar: 'https://i.pravatar.cc/150?img=12',
  //       customerPhone: '+92-301-9876543',
  //     ),
  //     ServiceWithCustomer(
  //       service: Service(
  //         id: 's3',
  //         workerId: 'w123',
  //         customerId: 'c3',
  //         serviceTitle: 'Custom Wardrobe Building',
  //         description:
  //             'Need custom wardrobe built for master bedroom with specific dimensions and design.',
  //         location: 'Villa 7, Garden Town, Wah Cantt',
  //         acceptedStatus: true,
  //         createdAt: now.subtract(const Duration(days: 1)),
  //         updatedAt: now.subtract(const Duration(hours: 12)),
  //       ),
  //       serviceDetails: ServiceDetails(
  //         serviceId: 's3',
  //         price: 15000,
  //         priceUnit: 'PKR',
  //         bookingDate: now.subtract(const Duration(hours: 12)),
  //         startDate: null,
  //         expectedEnd: now.add(const Duration(days: 5)),
  //         completedDate: null,
  //         paidStatus: false,
  //         createdAt: now.subtract(const Duration(hours: 12)),
  //         updatedAt: now.subtract(const Duration(hours: 12)),
  //       ),
  //       customerName: 'Hassan Raza',
  //       customerAvatar: 'https://i.pravatar.cc/150?img=13',
  //       customerPhone: '+92-333-4567890',
  //     ),
  //     ServiceWithCustomer(
  //       service: Service(
  //         id: 's4',
  //         workerId: 'w123',
  //         customerId: 'c4',
  //         serviceTitle: 'Full House Interior Painting',
  //         description:
  //             'Full house interior painting required. Approximately 2000 sq ft area including walls and ceilings.',
  //         location: 'House 15, Phase 2, Wah Cantt',
  //         acceptedStatus: false,
  //         createdAt: now.subtract(const Duration(hours: 8)),
  //         updatedAt: now.subtract(const Duration(hours: 8)),
  //       ),
  //       customerName: 'Ayesha Mahmood',
  //       customerAvatar: 'https://i.pravatar.cc/150?img=14',
  //       customerPhone: '+92-345-1122334',
  //     ),
  //     ServiceWithCustomer(
  //       service: Service(
  //         id: 's5',
  //         workerId: 'w123',
  //         customerId: 'c5',
  //         serviceTitle: 'AC Servicing & Gas Refill',
  //         description:
  //             'AC not cooling properly. Needs complete servicing and gas refill.',
  //         location: 'Apartment 2C, Star Residency, Wah Cantt',
  //         acceptedStatus: true,
  //         createdAt: now.subtract(const Duration(hours: 12)),
  //         updatedAt: now.subtract(const Duration(hours: 2)),
  //       ),
  //       serviceDetails: ServiceDetails(
  //         serviceId: 's5',
  //         price: 4500,
  //         priceUnit: 'PKR',
  //         bookingDate: now.subtract(const Duration(hours: 2)),
  //         startDate: now.subtract(const Duration(hours: 1)),
  //         expectedEnd: now.add(const Duration(hours: 2)),
  //         completedDate: null,
  //         paidStatus: false,
  //         createdAt: now.subtract(const Duration(hours: 2)),
  //         updatedAt: now.subtract(const Duration(hours: 1)),
  //       ),
  //       customerName: 'Usman Shah',
  //       customerAvatar: 'https://i.pravatar.cc/150?img=15',
  //       customerPhone: '+92-321-9988776',
  //     ),
  //     ServiceWithCustomer(
  //       service: Service(
  //         id: 's6',
  //         workerId: 'w123',
  //         customerId: 'c6',
  //         serviceTitle: 'Bathroom Drainage & Toilet Repair',
  //         description:
  //             'Bathroom drainage issue causing slow water flow and toilet flush mechanism needs repair.',
  //         location: 'House 89, Officer Colony, Wah Cantt',
  //         acceptedStatus: false,
  //         createdAt: now.subtract(const Duration(minutes: 45)),
  //         updatedAt: now.subtract(const Duration(minutes: 45)),
  //       ),
  //       customerName: 'Zainab Ahmed',
  //       customerAvatar: 'https://i.pravatar.cc/150?img=16',
  //       customerPhone: '+92-312-5566778',
  //     ),
  //     ServiceWithCustomer(
  //       service: Service(
  //         id: 's7',
  //         workerId: 'w123',
  //         customerId: 'c7',
  //         serviceTitle: 'Electrical Wiring Check',
  //         description:
  //             'Regular electrical wiring inspection and safety check for entire house.',
  //         location: 'House 42, Model Town, Wah Cantt',
  //         acceptedStatus: true,
  //         createdAt: now.subtract(const Duration(days: 3)),
  //         updatedAt: now.subtract(const Duration(days: 1)),
  //       ),
  //       serviceDetails: ServiceDetails(
  //         serviceId: 's7',
  //         price: 3000,
  //         priceUnit: 'PKR',
  //         bookingDate: now.subtract(const Duration(days: 1)),
  //         startDate: now.subtract(const Duration(days: 1)),
  //         expectedEnd: now.subtract(const Duration(hours: 2)),
  //         completedDate: now.subtract(const Duration(hours: 2)),
  //         paidStatus: true,
  //         createdAt: now.subtract(const Duration(days: 1)),
  //         updatedAt: now.subtract(const Duration(hours: 2)),
  //       ),
  //       customerName: 'Bilal Ahmed',
  //       customerAvatar: 'https://i.pravatar.cc/150?img=17',
  //       customerPhone: '+92-334-8877665',
  //     ),
  //   ];
  // }
}

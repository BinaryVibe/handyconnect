import '../../utils/customer_with_service.dart';
import '../models/service.dart';
import '../models/service_details.dart';

class ServiceRequestService {
  // TODO: Initialize Supabase client
  // final supabase = Supabase.instance.client;

  // Fetch all services for a worker with customer details
  Future<List<ServiceWithCustomer>> fetchWorkerServices(String workerId) async {
    try {
      // TODO: Replace with actual Supabase query with joins
      // final response = await supabase
      //     .from('services')
      //     .select('''
      //       *,
      //       service_details(*),
      //       customers:customer_id(first_name, last_name, avatar_url, phone_number)
      //     ''')
      //     .eq('worker_id', workerId)
      //     .order('created_at', ascending: false);
      
      // return (response as List).map((json) {
      //   final service = Service.fromJson(json);
      //   final serviceDetails = json['service_details'] != null
      //       ? ServiceDetails.fromJson(json['service_details'])
      //       : null;
      //   final customer = json['customers'];
      //   
      //   return ServiceWithCustomer(
      //     service: service,
      //     serviceDetails: serviceDetails,
      //     customerName: '${customer['first_name']} ${customer['last_name']}',
      //     customerAvatar: customer['avatar_url'],
      //     customerPhone: customer['phone_number'],
      //   );
      // }).toList();

      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));
      return _getMockServices();
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
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockServices()
          .where((service) => service.status == status)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  // Mock data generator
  List<ServiceWithCustomer> _getMockServices() {
    final now = DateTime.now();
    
    return [
      ServiceWithCustomer(
        service: Service(
          id: 's1',
          workerId: 'w123',
          customerId: 'c1',
          serviceTitle: 'Kitchen Sink Repair',
          description: 'Kitchen sink is leaking and needs urgent repair. Water is dripping constantly from the pipe connection.',
          location: 'House #123, Street 5, Wah Cantt',
          acceptedStatus: false,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        customerName: 'Ahmed Khan',
        customerAvatar: 'https://i.pravatar.cc/150?img=11',
        customerPhone: '+92-300-1234567',
      ),
      ServiceWithCustomer(
        service: Service(
          id: 's2',
          workerId: 'w123',
          customerId: 'c2',
          serviceTitle: 'Ceiling Fan Installation',
          description: 'Need to install ceiling fan in bedroom and fix two faulty switches in the living room.',
          location: 'Flat 4B, Al-Noor Plaza, Wah Cantt',
          acceptedStatus: false,
          createdAt: now.subtract(const Duration(hours: 5)),
          updatedAt: now.subtract(const Duration(hours: 5)),
        ),
        customerName: 'Fatima Ali',
        customerAvatar: 'https://i.pravatar.cc/150?img=12',
        customerPhone: '+92-301-9876543',
      ),
      ServiceWithCustomer(
        service: Service(
          id: 's3',
          workerId: 'w123',
          customerId: 'c3',
          serviceTitle: 'Custom Wardrobe Building',
          description: 'Need custom wardrobe built for master bedroom with specific dimensions and design.',
          location: 'Villa 7, Garden Town, Wah Cantt',
          acceptedStatus: true,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(hours: 12)),
        ),
        serviceDetails: ServiceDetails(
          id: 'sd3',
          serviceId: 's3',
          price: 15000,
          priceUnit: 'PKR',
          bookingDate: now.subtract(const Duration(hours: 12)),
          startDate: null,
          expectedEnd: now.add(const Duration(days: 5)),
          completedDate: null,
          paidStatus: false,
          createdAt: now.subtract(const Duration(hours: 12)),
          updatedAt: now.subtract(const Duration(hours: 12)),
        ),
        customerName: 'Hassan Raza',
        customerAvatar: 'https://i.pravatar.cc/150?img=13',
        customerPhone: '+92-333-4567890',
      ),
      ServiceWithCustomer(
        service: Service(
          id: 's4',
          workerId: 'w123',
          customerId: 'c4',
          serviceTitle: 'Full House Interior Painting',
          description: 'Full house interior painting required. Approximately 2000 sq ft area including walls and ceilings.',
          location: 'House 15, Phase 2, Wah Cantt',
          acceptedStatus: false,
          createdAt: now.subtract(const Duration(hours: 8)),
          updatedAt: now.subtract(const Duration(hours: 8)),
        ),
        customerName: 'Ayesha Mahmood',
        customerAvatar: 'https://i.pravatar.cc/150?img=14',
        customerPhone: '+92-345-1122334',
      ),
      ServiceWithCustomer(
        service: Service(
          id: 's5',
          workerId: 'w123',
          customerId: 'c5',
          serviceTitle: 'AC Servicing & Gas Refill',
          description: 'AC not cooling properly. Needs complete servicing and gas refill.',
          location: 'Apartment 2C, Star Residency, Wah Cantt',
          acceptedStatus: true,
          createdAt: now.subtract(const Duration(hours: 12)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        serviceDetails: ServiceDetails(
          id: 'sd5',
          serviceId: 's5',
          price: 4500,
          priceUnit: 'PKR',
          bookingDate: now.subtract(const Duration(hours: 2)),
          startDate: now.subtract(const Duration(hours: 1)),
          expectedEnd: now.add(const Duration(hours: 2)),
          completedDate: null,
          paidStatus: false,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
        customerName: 'Usman Shah',
        customerAvatar: 'https://i.pravatar.cc/150?img=15',
        customerPhone: '+92-321-9988776',
      ),
      ServiceWithCustomer(
        service: Service(
          id: 's6',
          workerId: 'w123',
          customerId: 'c6',
          serviceTitle: 'Bathroom Drainage & Toilet Repair',
          description: 'Bathroom drainage issue causing slow water flow and toilet flush mechanism needs repair.',
          location: 'House 89, Officer Colony, Wah Cantt',
          acceptedStatus: false,
          createdAt: now.subtract(const Duration(minutes: 45)),
          updatedAt: now.subtract(const Duration(minutes: 45)),
        ),
        customerName: 'Zainab Ahmed',
        customerAvatar: 'https://i.pravatar.cc/150?img=16',
        customerPhone: '+92-312-5566778',
      ),
      ServiceWithCustomer(
        service: Service(
          id: 's7',
          workerId: 'w123',
          customerId: 'c7',
          serviceTitle: 'Electrical Wiring Check',
          description: 'Regular electrical wiring inspection and safety check for entire house.',
          location: 'House 42, Model Town, Wah Cantt',
          acceptedStatus: true,
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        serviceDetails: ServiceDetails(
          id: 'sd7',
          serviceId: 's7',
          price: 3000,
          priceUnit: 'PKR',
          bookingDate: now.subtract(const Duration(days: 1)),
          startDate: now.subtract(const Duration(days: 1)),
          expectedEnd: now.subtract(const Duration(hours: 2)),
          completedDate: now.subtract(const Duration(hours: 2)),
          paidStatus: true,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        customerName: 'Bilal Ahmed',
        customerAvatar: 'https://i.pravatar.cc/150?img=17',
        customerPhone: '+92-334-8877665',
      ),
    ];
  }
}
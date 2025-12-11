// Combined Service with Customer Info (for display purposes)
import '../src/models/service.dart';
import '../src/models/service_details.dart';

class ServiceWithCustomer {
  final Service service;
  final ServiceDetails? serviceDetails;
  final String customerName;
  final String? customerAvatar;
  final String? customerPhone;

  ServiceWithCustomer({
    required this.service,
    this.serviceDetails,
    required this.customerName,
    this.customerAvatar,
    this.customerPhone,
  });

  // Helper to get service status
  String get status {
    if (!service.acceptedStatus) return 'pending';
    if (serviceDetails == null) return 'accepted';
    if (serviceDetails!.completedDate != null) return 'completed';
    if (serviceDetails!.startDate != null) return 'in_progress';
    return 'accepted';
  }
}

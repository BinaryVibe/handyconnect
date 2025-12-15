import 'package:handyconnect/models/service.dart';
import 'package:handyconnect/models/service_details.dart';

class ServiceWithWorker {
  final Service service;
  final ServiceDetails? serviceDetails;
  final String workerName;
  final String? workerAvatar;
  final String? workerPhone;
  final String workerProfession;

  ServiceWithWorker({
    required this.service,
    this.serviceDetails,
    required this.workerName,
    this.workerAvatar,
    this.workerPhone,
    required this.workerProfession,
  });

  String get status {
    if (!service.acceptedStatus) return 'pending';
    if (serviceDetails == null) return 'accepted';
    if (serviceDetails!.completedDate != null) return 'completed';
    if (serviceDetails!.startDate != null) return 'in_progress';
    return 'accepted';
  }
}

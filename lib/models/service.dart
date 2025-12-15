class Service {
  final String id;
  final String workerId;
  final String customerId;

  final String serviceTitle;
  final String? description;
  final String? location;

  final bool acceptedStatus;

  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.workerId,
    required this.customerId,
    required this.serviceTitle,
    this.description,
    this.location,
    required this.acceptedStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      workerId: json['worker_id'],
      customerId: json['customer_id'],
      serviceTitle: json['service_title'],
      description: json['description'],
      location: json['location'],
      acceptedStatus: json['accepted_status'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'customer_id': customerId,
      'service_title': serviceTitle,
      'description': description,
      'location': location,
      'accepted_status': acceptedStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Service {
  final String id;                  
  final String workerId;            
  final String customerId;         

  final String serviceTitle;
  final String? description;

  final double? price;
  final String? priceUnit;          

  final bool acceptedStatus;
  final String? location;

  final DateTime createdAt;
  final DateTime updatedAt;

  final DateTime? bookingDate;
  final DateTime? startDate;
  final DateTime? expectedEnd;
  final DateTime? completedDate;

  final bool paidStatus;

  Service({
    required this.id,
    required this.workerId,
    required this.customerId,
    required this.serviceTitle,
    required this.description,
    required this.price,
    required this.priceUnit,
    required this.acceptedStatus,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.bookingDate,
    required this.startDate,
    required this.expectedEnd,
    required this.completedDate,
    required this.paidStatus,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      workerId: json['worker_id'],
      customerId: json['customer_id'],
      serviceTitle: json['service_title'],
      description: json['description'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      priceUnit: json['price_unit'],
      acceptedStatus: json['accepted_status'] ?? false,
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      bookingDate: json['booking_date'] != null ? DateTime.parse(json['booking_date']) : null,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      expectedEnd: json['expected_end'] != null ? DateTime.parse(json['expected_end']) : null,
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
      paidStatus: json['paidstatus'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'customer_id': customerId,
      'service_title': serviceTitle,
      'description': description,
      'price': price,
      'price_unit': priceUnit,
      'accepted_status': acceptedStatus,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'booking_date': bookingDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'expected_end': expectedEnd?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'paidstatus': paidStatus,
    };
  }
}

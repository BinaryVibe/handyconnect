class ServiceDetails {
  final String serviceId;

  final double? price;
  final String? priceUnit;

  final DateTime? startDate;
  final DateTime? expectedEnd;
  final DateTime? completedDate;

  final bool paidStatus;

  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceDetails({
    required this.serviceId,
    this.price,
    this.priceUnit,
    this.startDate,
    this.expectedEnd,
    this.completedDate,
    this.paidStatus = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      serviceId: json['service_id'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      priceUnit: json['price_unit'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      expectedEnd: json['expected_end'] != null
          ? DateTime.parse(json['expected_end'])
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      paidStatus: json['paid_status'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'price': price,
      'price_unit': priceUnit,
      'start_date': startDate?.toIso8601String(),
      'expected_end': expectedEnd?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'paid_status': paidStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

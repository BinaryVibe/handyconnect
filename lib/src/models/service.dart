class Service {
  final int serviceId;
  final int workerId;
  final String serviceName;
  final String category;
  final String description;
  final String priceUnit;
  final String status;
  final String location;
  final double rating;

  Service({
    required this.serviceId,
    required this.workerId,
    required this.serviceName,
    required this.category,
    required this.description,
    required this.priceUnit,
    required this.status,
    required this.location,
    required this.rating,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'],
      workerId: json['workerId'],
      serviceName: json['serviceName'],
      category: json['category'],
      description: json['description'],
      priceUnit: json['priceUnit'],
      status: json['status'],
      location: json['location'],
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'workerId': workerId,
      'serviceName': serviceName,
      'category': category,
      'description': description,
      'priceUnit': priceUnit,
      'status': status,
      'location': location,
      'rating': rating,
    };
  }
}
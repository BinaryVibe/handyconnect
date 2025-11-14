class Booking {
  final int bookingId;
  final int customerId;
  final int workerId;
  final int serviceId;
  final DateTime bookingDate;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String serviceType;
  final DateTime? completionDate;
  final String location;

  Booking({
    required this.bookingId,
    required this.customerId,
    required this.workerId,
    required this.serviceId,
    required this.bookingDate,
    required this.scheduledDate,
    this.completedDate,
    required this.serviceType,
    this.completionDate,
    required this.location,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['bookingId'],
      customerId: json['customerId'],
      workerId: json['workerId'],
      serviceId: json['serviceId'],
      bookingDate: DateTime.parse(json['bookingDate']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      serviceType: json['serviceType'],
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'workerId': workerId,
      'serviceId': serviceId,
      'bookingDate': bookingDate.toIso8601String(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'serviceType': serviceType,
      'completionDate': completionDate?.toIso8601String(),
      'location': location,
    };
  }
}
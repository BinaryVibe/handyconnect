class Address {
  final String id;              // uuid
  final String customerId;      // uuid

  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  final DateTime createdAt;

  Address({
    required this.id,
    required this.customerId,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      customerId: json['customer_id'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

import 'user.dart';

class Customer extends User {
  final String address;
  final DateTime dateJoined;

  Customer({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.avatarUrl,
    required this.address,
    required this.dateJoined,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      avatarUrl: json['avatar_url'],
      dateJoined: DateTime.parse(json['date_joined']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'avatar_url': avatarUrl,
      'date_joined': dateJoined.toIso8601String(),
    };
  }
}

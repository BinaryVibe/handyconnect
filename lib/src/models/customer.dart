class Customer {
  final int customerId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final String address;
  final String? avatarUrl;
  final DateTime dateJoined;

  Customer({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.address,
    this.avatarUrl,
    required this.dateJoined,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      avatarUrl: json['avatarUrl'],
      dateJoined: DateTime.parse(json['dateJoined']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'firstName': firstName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'avatarUrl': avatarUrl,
      'dateJoined': dateJoined.toIso8601String(),
    };
  }
}
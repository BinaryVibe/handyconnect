class Customer {
  final int customerId;
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String address;
  final String profilePicture;
  final DateTime dateJoined;

  Customer({
    required this.customerId,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.address,
    required this.profilePicture,
    required this.dateJoined,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      profilePicture: json['profilePicture'],
      dateJoined: DateTime.parse(json['dateJoined']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePicture': profilePicture,
      'dateJoined': dateJoined.toIso8601String(),
    };
  }
}
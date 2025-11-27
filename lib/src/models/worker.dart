class Worker {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final String profession;
  final List<String> skills;
  final bool availability;
  final double avgRating;
  final bool verifiedStatus;
  final double earnings;
  final String? profilePicture;

  Worker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.profession,
    required this.skills,
    required this.availability,
    this.avgRating = 0.0,
    required this.verifiedStatus,
    this.earnings = 0.0,
    required this.profilePicture,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      firstName: json['firstName' ],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      profession: json['profession'],
      skills: List<String>.from(json['skills'] ?? []),
      availability: json['availability'] ?? false,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      verifiedStatus: json['verifiedStatus'] ?? false,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'profession': profession,
      'skills': skills,
      'availability': availability,
      'avgRating': avgRating,
      'verifiedStatus': verifiedStatus,
      'earnings': earnings,
      'profilePicture': profilePicture,
    };
  }
}

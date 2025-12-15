import 'user.dart';

class Worker extends User {
  final String profession;
  final List<String> skills;
  final bool availability;
  final double avgRating;
  final bool verifiedStatus;
  final double earnings;

  Worker({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.avatarUrl,
    required this.profession,
    required this.skills,
    required this.availability,
    this.avgRating = 0.0,
    required this.verifiedStatus,
    this.earnings = 0.0,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as String,
      firstName: json['profiles']['first_name'] as String,
      lastName: json['profiles']['last_name'] as String,
      email: json['profiles']['email'] as String,
      phoneNumber: json['profiles']['phone_number'] as String,
      avatarUrl: json['profiles']['avatar_url'] as String?,
      profession: json['profession'] as String,
      skills: List<String>.from(json['skills'] ?? []),
      availability: json['availability'] as bool,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      verifiedStatus: json['verified_status'] as bool,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'profession': profession,
      'skills': skills,
      'availability': availability,
      'avg_rating': avgRating,
      'verified_status': verifiedStatus,
      'earnings': earnings,
    };
  }
}

class Review {
  final int reviewId;
  final int bookingId;
  final int customerId;
  final int workerId;
  final int serviceId;
  final double rating;
  final String comment;
  final DateTime date;
  final String image;

  Review({
    required this.reviewId,
    required this.bookingId,
    required this.customerId,
    required this.workerId,
    required this.serviceId,
    required this.rating,
    required this.comment,
    required this.date,
    required this.image,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'],
      bookingId: json['bookingId'],
      customerId: json['customerId'],
      workerId: json['workerId'],
      serviceId: json['serviceId'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      date: DateTime.parse(json['date']),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'bookingId': bookingId,
      'customerId': customerId,
      'workerId': workerId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'image': image,
    };
  }
}
class Review {
  final String reviewId;          // uuid
  final String customerId;        // uuid
  final String workerId;          // uuid
  final String serviceId;         // uuid

  final int rating;               // integer
  final String? comment;          // nullable
  final DateTime reviewDate;      // review_date
  final List<String>? images;     // text[] nullable

  Review({
    required this.reviewId,
    required this.customerId,
    required this.workerId,
    required this.serviceId,
    required this.rating,
    required this.comment,
    required this.reviewDate,
    required this.images,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      customerId: json['customer_id'],
      workerId: json['worker_id'],
      serviceId: json['service_id'],
      rating: json['rating'],
      comment: json['comment'],
      reviewDate: DateTime.parse(json['review_date']),
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'customer_id': customerId,
      'worker_id': workerId,
      'service_id': serviceId,
      'rating': rating,
      'comment': comment,
      'review_date': reviewDate.toIso8601String(),
      'images': images,
    };
  }
}

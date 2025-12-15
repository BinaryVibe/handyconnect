import 'package:flutter/foundation.dart';
import '../models/review.dart';

class ReviewProvider extends ChangeNotifier {
  final List<Review> _reviews = [];

  List<Review> get reviews => _reviews;

  Future<void> addReview(Review review) async {
    // TODO: Implement Firebase or API add logic
    notifyListeners();
  }

  Future<void> fetchReviews() async {
    // TODO: Implement Firebase or API fetch logic
    notifyListeners();
  }

  Future<void> updateReview(Review review) async {
    // TODO: Implement Firebase or API update logic
    notifyListeners();
  }

  Future<void> deleteReview(int reviewId) async {
    // TODO: Implement Firebase or API delete logic
    notifyListeners();
  }

  List<Review> getReviewsByWorker(int workerId) {
    return _reviews.where((r) => r.workerId == workerId).toList();
  }

  List<Review> getReviewsByService(int serviceId) {
    return _reviews.where((r) => r.serviceId == serviceId).toList();
  }
}

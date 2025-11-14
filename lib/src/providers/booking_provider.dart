import 'package:flutter/foundation.dart';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => _bookings;

  Future<void> addBooking(Booking booking) async {
    // TODO: Implement Firebase add logic
    notifyListeners();
  }

  Future<void> fetchBookings() async {
    // TODO: Implement Firebase fetch logic
    notifyListeners();
  }

  Future<void> updateBooking(Booking booking) async {
    // TODO: Implement Firebase update logic
    notifyListeners();
  }

  Future<void> deleteBooking(String id) async {
    // TODO: Implement Firebase delete logic
    notifyListeners();
  }
}

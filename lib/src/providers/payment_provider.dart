import 'package:flutter/foundation.dart';
import '../models/payment.dart';

class PaymentProvider extends ChangeNotifier {
  final List<Payment> _payments = [];

  List<Payment> get payments => _payments;

  Future<void> addPayment(Payment payment) async {
    // TODO: Implement Firebase or API add logic
    notifyListeners();
  }

  Future<void> fetchPayments() async {
    // TODO: Implement Firebase or API fetch logic
    notifyListeners();
  }

  Future<void> updatePayment(Payment payment) async {
    // TODO: Implement Firebase or API update logic
    notifyListeners();
  }

  Future<void> deletePayment(int paymentId) async {
    // TODO: Implement Firebase or API delete logic
    notifyListeners();
  }

  Payment? getPaymentById(int id) {
    try {
      return _payments.firstWhere((p) => p.paymentId == id);
    } catch (_) {
      return null;
    }
  }
}

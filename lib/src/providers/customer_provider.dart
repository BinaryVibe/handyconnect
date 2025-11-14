import 'package:flutter/foundation.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  Future<void> addCustomer(Customer customer) async {
    // TODO: Implement Firebase add logic
    notifyListeners();
  }

  Future<void> fetchCustomers() async {
    // TODO: Implement Firebase fetch logic
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    // TODO: Implement Firebase update logic
    notifyListeners();
  }

  Future<void> deleteCustomer(String id) async {
    // TODO: Implement Firebase delete logic
    notifyListeners();
  }
}

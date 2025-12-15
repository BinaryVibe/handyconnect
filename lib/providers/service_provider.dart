import 'package:flutter/foundation.dart';
import '../models/service.dart';

class ServiceProvider extends ChangeNotifier {
  final List<Service> _services = [];

  List<Service> get services => _services;

  Future<void> addService(Service service) async {
    // TODO: Implement Firebase add logic
    notifyListeners();
  }

  Future<void> fetchServices() async {
    // TODO: Implement Firebase fetch logic
    notifyListeners();
  }

  Future<void> updateService(Service service) async {
    // TODO: Implement Firebase update logic
    notifyListeners();
  }

  Future<void> deleteService(String id) async {
    // TODO: Implement Firebase delete logic
    notifyListeners();
  }
}


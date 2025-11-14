import 'package:flutter/foundation.dart';
import '../models/admin.dart';

class AdminProvider extends ChangeNotifier {
  final List<Admin> _admins = [];

  List<Admin> get admins => _admins;

  Future<void> addAdmin(Admin admin) async {
    // TODO: Implement Firebase add logic
    notifyListeners();
  }

  Future<void> fetchAdmins() async {
    // TODO: Implement Firebase fetch logic
    notifyListeners();
  }

  Future<void> updateAdmin(Admin admin) async {
    // TODO: Implement Firebase update logic
    notifyListeners();
  }

  Future<void> deleteAdmin(String id) async {
    // TODO: Implement Firebase delete logic
    notifyListeners();
  }
}


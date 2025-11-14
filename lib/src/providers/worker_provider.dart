import 'package:flutter/foundation.dart';
import '../models/worker.dart';

class WorkerProvider extends ChangeNotifier {
  final List<Worker> _workers = [];

  List<Worker> get workers => _workers;

  Future<void> addWorker(Worker worker) async {
    // TODO: Implement Firebase add logic
    notifyListeners();
  }

  Future<void> fetchWorkers() async {
    // TODO: Implement Firebase fetch logic
    notifyListeners();
  }

  Future<void> updateWorker(Worker worker) async {
    // TODO: Implement Firebase update logic
    notifyListeners();
  }

  Future<void> deleteWorker(String id) async {
    // TODO: Implement Firebase delete logic
    notifyListeners();
  }
}

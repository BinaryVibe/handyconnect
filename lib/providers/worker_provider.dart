import '../models/worker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerSupabaseService {
  final _supabase = Supabase.instance.client;
  late final _userId = _supabase.auth.currentUser?.id;

  // Fetch all workers
  Future<List<Worker>> fetchWorkers() async {
    try {
      final response = await _supabase
          .from('workers')
          .select('*, profiles(id, *)');
      // print(response as List);
      return (response as List).map((json) => Worker.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workers: $e');
    }
  }

  // Search workers by profession or skills
  Future<List<Worker>> searchWorkers(String query) async {
    try {
      final response = await _supabase
          .from('workers')
          .select('*, profiles(id, *)')
          .or('profession.ilike.%$query%,skills.cs.{$query}');
      return (response as List).map((json) => Worker.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search workers: $e');
    }
  }

  Future<void> insertWorker(Map<String, dynamic> workerData) async {
    workerData['id'] = _userId;
    try {
      await _supabase.from('workers').insert(workerData);
    } catch (e) {
      throw Exception('Failed to insert Worker');
    }
  }

  // Mock data generator
  // List<Worker> _getMockWorkers() {
  //   return [
  //     Worker(
  //       id: '1',
  //       firstName: 'John',
  //       lastName: 'Smith',
  //       email: 'john.smith@example.com',
  //       phoneNumber: '+1234567890',
  //       avatarUrl: 'https://i.pravatar.cc/150?img=1',
  //       profession: 'Plumber',
  //       skills: ['Pipe Repair', 'Drain Cleaning', 'Water Heater'],
  //       availability: true,
  //       avgRating: 4.8,
  //       verifiedStatus: true,
  //       earnings: 45000,
  //     ),
  //     Worker(
  //       id: '2',
  //       firstName: 'Sarah',
  //       lastName: 'Johnson',
  //       email: 'sarah.j@example.com',
  //       phoneNumber: '+1234567891',
  //       avatarUrl: 'https://i.pravatar.cc/150?img=2',
  //       profession: 'Electrician',
  //       skills: ['Wiring', 'Circuit Breaker', 'Lighting Installation'],
  //       availability: true,
  //       avgRating: 4.9,
  //       verifiedStatus: true,
  //       earnings: 52000,
  //     ),
  //     Worker(
  //       id: '3',
  //       firstName: 'Mike',
  //       lastName: 'Davis',
  //       email: 'mike.d@example.com',
  //       phoneNumber: '+1234567892',
  //       avatarUrl: 'https://i.pravatar.cc/150?img=3',
  //       profession: 'Carpenter',
  //       skills: ['Furniture', 'Framing', 'Cabinet Making'],
  //       availability: false,
  //       avgRating: 4.6,
  //       verifiedStatus: true,
  //       earnings: 38000,
  //     ),
  //     Worker(
  //       id: '4',
  //       firstName: 'Emily',
  //       lastName: 'Brown',
  //       email: 'emily.b@example.com',
  //       phoneNumber: '+1234567893',
  //       avatarUrl: 'https://i.pravatar.cc/150?img=4',
  //       profession: 'Painter',
  //       skills: ['Interior Painting', 'Exterior Painting', 'Wallpaper'],
  //       availability: true,
  //       avgRating: 4.7,
  //       verifiedStatus: false,
  //       earnings: 32000,
  //     ),
  //     Worker(
  //       id: '5',
  //       firstName: 'David',
  //       lastName: 'Wilson',
  //       email: 'david.w@example.com',
  //       phoneNumber: '+1234567894',
  //       avatarUrl: 'https://i.pravatar.cc/150?img=5',
  //       profession: 'HVAC Technician',
  //       skills: ['AC Repair', 'Heating', 'Ventilation'],
  //       availability: true,
  //       avgRating: 4.5,
  //       verifiedStatus: true,
  //       earnings: 48000,
  //     ),
  //   ];
  // }
}

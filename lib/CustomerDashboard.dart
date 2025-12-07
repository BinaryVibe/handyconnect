import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/models/worker.dart';

const Color kPrimaryColor = Color.fromARGB(
  255,
  74,
  46,
  30,
); // buttons + headings
const Color kFieldColor = Color(0xFFE9DFD8); // input backgrounds
const Color kBackgroundColor = Color(0xFFF7F2EF); // main background
const Color listTileColor = Color(0xFFAD8042);
const Color secondaryTextColor = Color(0xFFBFAB67);
const Color tagsBgColor = Color(0xFFBFC882);

// Supabase Service (Ready for integration)
class SupabaseService {
  final supabase = Supabase.instance.client;

  // Fetch all workers
  Future<List<Worker>> fetchWorkers() async {
    try {
      // TODO: Replace with actual Supabase query
      // final response = await supabase.from('workers').select();
      // return (response as List).map((json) => Worker.fromJson(json)).toList();

      // Mock data for demonstration
      await Future.delayed(const Duration(seconds: 1));
      return _getMockWorkers();
    } catch (e) {
      throw Exception('Failed to fetch workers: $e');
    }
  }

  // Search workers by profession or skills
  Future<List<Worker>> searchWorkers(String query) async {
    try {
      // TODO: Replace with actual Supabase query
      // final response = await supabase
      //     .from('workers')
      //     .select()
      //     .or('profession.ilike.%$query%,skills.cs.{$query}');
      // return (response as List).map((json) => Worker.fromJson(json)).toList();

      // Mock search for demonstration
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockWorkers()
          .where(
            (w) =>
                w.profession.toLowerCase().contains(query.toLowerCase()) ||
                w.skills.any(
                  (s) => s.toLowerCase().contains(query.toLowerCase()),
                ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search workers: $e');
    }
  }

  // Mock data generator
  List<Worker> _getMockWorkers() {
    return [
      Worker(
        id: '1',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john.smith@example.com',
        phoneNumber: '+1234567890',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        profession: 'Plumber',
        skills: ['Pipe Repair', 'Drain Cleaning', 'Water Heater'],
        availability: true,
        avgRating: 4.8,
        verifiedStatus: true,
        earnings: 45000,
      ),
      Worker(
        id: '2',
        firstName: 'Sarah',
        lastName: 'Johnson',
        email: 'sarah.j@example.com',
        phoneNumber: '+1234567891',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        profession: 'Electrician',
        skills: ['Wiring', 'Circuit Breaker', 'Lighting Installation'],
        availability: true,
        avgRating: 4.9,
        verifiedStatus: true,
        earnings: 52000,
      ),
      Worker(
        id: '3',
        firstName: 'Mike',
        lastName: 'Davis',
        email: 'mike.d@example.com',
        phoneNumber: '+1234567892',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        profession: 'Carpenter',
        skills: ['Furniture', 'Framing', 'Cabinet Making'],
        availability: false,
        avgRating: 4.6,
        verifiedStatus: true,
        earnings: 38000,
      ),
      Worker(
        id: '4',
        firstName: 'Emily',
        lastName: 'Brown',
        email: 'emily.b@example.com',
        phoneNumber: '+1234567893',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
        profession: 'Painter',
        skills: ['Interior Painting', 'Exterior Painting', 'Wallpaper'],
        availability: true,
        avgRating: 4.7,
        verifiedStatus: false,
        earnings: 32000,
      ),
      Worker(
        id: '5',
        firstName: 'David',
        lastName: 'Wilson',
        email: 'david.w@example.com',
        phoneNumber: '+1234567894',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        profession: 'HVAC Technician',
        skills: ['AC Repair', 'Heating', 'Ventilation'],
        availability: true,
        avgRating: 4.5,
        verifiedStatus: true,
        earnings: 48000,
      ),
    ];
  }
}

// Main Dashboard Screen
class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Worker> _workers = [];
  List<Worker> _filteredWorkers = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    try {
      final workers = await _supabaseService.fetchWorkers();
      setState(() {
        _workers = workers;
        _filteredWorkers = workers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load workers');
    }
  }

  void _searchWorkers(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredWorkers = _workers);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _supabaseService.searchWorkers(query);
      setState(() {
        _filteredWorkers = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Search failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: kBackgroundColor,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                // margin: EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(color: kPrimaryColor),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Welcome!",
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () => {},
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    _buildSearchBar(),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredWorkers.isEmpty
                    ? _buildEmptyState()
                    : _buildWorkerList(),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _searchWorkers,
      decoration: InputDecoration(
        hintText: 'Search by profession or skill...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchWorkers('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: kFieldColor,
      ),
    );
  }

  Widget _buildWorkerList() {
    return RefreshIndicator(
      onRefresh: _loadWorkers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredWorkers.length,
        itemBuilder: (context, index) {
          return WorkerCard(worker: _filteredWorkers[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No workers found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[700],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Worker Card Widget
class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: listTileColor,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to worker detail page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View ${worker.firstName}\'s profile')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(worker.avatarUrl!),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${worker.firstName} ${worker.lastName}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (worker.verifiedStatus) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          worker.profession,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            worker.avgRating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: worker.availability
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          worker.availability ? 'Available' : 'Busy',
                          style: TextStyle(
                            fontSize: 12,
                            color: worker.availability
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: worker.skills
                    .take(3)
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tagsBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF3E4C22),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

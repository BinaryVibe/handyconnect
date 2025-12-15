import 'package:flutter/material.dart';
import 'package:handyconnect/components/customer_service_card.dart';
import 'package:handyconnect/utils/service_with_worker.dart';
import '../providers/service_provider.dart';

// Color Constants
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color listTileColor = Color(0xFFad8042);
const Color secondaryTextColor = Color(0xFFBFAB67);
const Color tagsBgColor = Color(0xFFBFC882);
const Color professionColor = Color(0xFFede0d4);
const Color nameColor = Color(0xFFe6ccb2);

// Customer Bookings Widget
class CustomerBookingsPage extends StatefulWidget {
  const CustomerBookingsPage({super.key});

  @override
  State<CustomerBookingsPage> createState() => _CustomerBookingsPageState();
}

class _CustomerBookingsPageState extends State<CustomerBookingsPage> {
  final CustomerServiceHandler _serviceService = CustomerServiceHandler();
  final String _customerId = 'c123'; // TODO: Get from auth

  List<ServiceWithWorker> _services = [];
  List<ServiceWithWorker> _filteredServices = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await _serviceService.fetchCustomerServices(_customerId);
      setState(() {
        _services = services;
        _filteredServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load bookings');
    }
  }

  void _filterServices(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'all') {
        _filteredServices = _services;
      } else {
        _filteredServices = _services
            .where((service) => service.status == filter)
            .toList();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  int get _pendingCount =>
      _services.where((s) => s.status == 'pending').length;
  int get _acceptedCount =>
      _services.where((s) => s.status == 'accepted').length;
  int get _inProgressCount =>
      _services.where((s) => s.status == 'in_progress').length;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(color: kPrimaryColor),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Bookings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadServices,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildStatCards(),
              const SizedBox(height: 10),
              _buildFilterChips(),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredServices.isEmpty
                  ? _buildEmptyState()
                  : _buildServiceList(),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Pending',
            _pendingCount.toString(),
            Icons.pending_actions,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Accepted',
            _acceptedCount.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'In Progress',
            _inProgressCount.toString(),
            Icons.pending,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kFieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Pending', 'pending'),
          const SizedBox(width: 8),
          _buildFilterChip('Accepted', 'accepted'),
          const SizedBox(width: 8),
          _buildFilterChip('In Progress', 'in_progress'),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', 'completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _filterServices(value),
      backgroundColor: kFieldColor,
      selectedColor: tagsBgColor,
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF3E4C22) : kPrimaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildServiceList() {
    return RefreshIndicator(
      onRefresh: _loadServices,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                return CustomerServiceCard(
                  serviceWithWorker: _filteredServices[index],
                  onTap: () => _navigateToDetails(_filteredServices[index]),
                );
              },
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredServices.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width ~/ 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              return CustomerServiceCard(
                serviceWithWorker: _filteredServices[index],
                onTap: () => _navigateToDetails(_filteredServices[index]),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDetails(ServiceWithWorker serviceWithWorker) {
    // TODO: Navigate to service detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View details for: ${serviceWithWorker.service.serviceTitle}'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by hiring a worker from the home page',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

// --- Theme Constants ---
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color kAcceptColor = Color(0xFF4CAF50);
const Color kDeclineColor = Color(0xFFD32F2F);

class ServiceRequestDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceRequestDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceRequestDetailsScreen> createState() => _ServiceRequestDetailsScreenState();
}

class _ServiceRequestDetailsScreenState extends State<ServiceRequestDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _serviceData;
  Map<String, dynamic>? _customerProfile;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final client = Supabase.instance.client;

      // 1. Fetch Service Data
      final service = await client
          .from('services')
          .select()
          .eq('id', widget.serviceId)
          .single();

      // 2. Fetch Customer Profile
      final customerId = service['customer_id'];
      final profile = await client
          .from('profiles')
          .select()
          .eq('id', customerId)
          .single();

      if (mounted) {
        setState(() {
          _serviceData = service;
          _customerProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(bool accepted) async {
    try {
      setState(() => _isLoading = true);
      
      await Supabase.instance.client
          .from('services')
          .update({'accepted_status': accepted})
          .eq('id', widget.serviceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accepted ? 'Job Accepted!' : 'Job Declined'),
            backgroundColor: accepted ? kAcceptColor : kDeclineColor,
          ),
        );
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    if (_serviceData == null || _customerProfile == null) {
      return const Scaffold(body: Center(child: Text("Service not found")));
    }

    final avatarUrl = _customerProfile!['avatar_url'];
    final firstName = _customerProfile!['first_name'] ?? 'Unknown';
    final lastName = _customerProfile!['last_name'] ?? 'Customer';
    final location = _serviceData!['location'] ?? 'No location provided';
    final title = _serviceData!['service_title'] ?? 'No Title';
    final description = _serviceData!['description'] ?? 'No Description';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text("Job Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // --- Background Header Block (Brown) ---
          Container(
            height: 100,
            color: kPrimaryColor,
          ),
          
          // --- Main Content ---
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40), 
                
                // --- 1. Customer Profile Header ---
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: kBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl == null 
                              ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "$firstName $lastName",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                Text(
                  "Customer",
                  style: TextStyle(fontSize: 14, color: Colors.brown[400]),
                ),
                
                const SizedBox(height: 30),

                // --- 2. Location & Title Card (Removed Time) ---
                _buildInfoCard(
                  title: "Service Details",
                  icon: Icons.work,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.title, "Title", title),
                      const Divider(height: 24),
                      _buildDetailRow(Icons.location_on, "Location", location),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- 3. Description Card ---
                _buildInfoCard(
                  title: "Description",
                  icon: Icons.description,
                  child: Text(
                    description,
                    style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),

                // --- 4. Action Buttons ---
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () => _updateStatus(false), // Decline
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kDeclineColor, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Decline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDeclineColor)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(true), // Accept
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Accept Job", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: kFieldColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kPrimaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
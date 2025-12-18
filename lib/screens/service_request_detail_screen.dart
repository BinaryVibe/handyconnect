import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// --- IMPORT THE NEW PROVIDER FILE ---
import '../providers/service_request_provider.dart';

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
  // --- Initialize the Provider ---
  final ServiceRequestHandler _requestHandler = ServiceRequestHandler();

  // --- State Variables ---
  bool _isLoading = true;
  bool _showInputFields = false;
  Map<String, dynamic>? _serviceData;
  Map<String, dynamic>? _customerProfile;

  // --- Input Controllers ---
  final _priceController = TextEditingController();
  DateTime? _estimatedEndDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // --- 1. Fetch Data (Using Provider) ---
  Future<void> _fetchData() async {
    try {
      final data = await _requestHandler.fetchRequestDetails(widget.serviceId);

      if (mounted) {
        setState(() {
          _serviceData = data.serviceData;
          _customerProfile = data.customerProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 2. Decline Logic (Using Provider) ---
  Future<void> _handleDecline() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Decline Job"),
        content: const Text("Are you sure? This will remove the request permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Decline", style: TextStyle(color: kDeclineColor))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _requestHandler.declineService(widget.serviceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request declined.'), backgroundColor: kDeclineColor),
        );
        context.pop(); // Return to Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 3. Accept Logic (UI Only) ---
  void _handleAcceptPress() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Accept Job"),
        content: const Text("You are about to accept this job. Please provide a price estimate."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _showInputFields = true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: const Text("Proceed", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 4. Final Submission (Using Provider) ---
  Future<void> _submitFinalAcceptance() async {
    if (_priceController.text.isEmpty || _estimatedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Price and Estimated End Date")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _requestHandler.acceptService(
        serviceId: widget.serviceId,
        price: double.parse(_priceController.text.trim()),
        estimatedEndDate: _estimatedEndDate!.toIso8601String(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job Accepted!'), backgroundColor: kAcceptColor),
        );
        context.pop(); // Return to Dashboard
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // --- Date Picker Helper ---
  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white, 
              onSurface: kPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _estimatedEndDate = picked);
  }

  // --- UI Build ---
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
          Container(height: 100, color: kPrimaryColor),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: kBackgroundColor, shape: BoxShape.circle),
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
                Text("$firstName $lastName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                Text("Customer", style: TextStyle(fontSize: 14, color: Colors.brown[400])),
                const SizedBox(height: 30),

                // --- Service Info ---
                _buildInfoCard(
                  title: "Service Details",
                  icon: Icons.work,
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.title, "Title", title),
                      const Divider(height: 24),
                      _buildDetailRow(Icons.location_on, "Location", location),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: "Description",
                  icon: Icons.description,
                  child: Text(description, style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.5)),
                ),
                const SizedBox(height: 40),

                // --- Buttons / Inputs ---
                if (!_showInputFields)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            onPressed: _handleDecline,
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
                            onPressed: _handleAcceptPress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Accept Job", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  _buildInputForm(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Finalize Agreement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          const SizedBox(height: 20),
          
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Agreed Price",
              prefixText: "\$ ",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: kFieldColor,
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: _pickEndDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: kFieldColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _estimatedEndDate == null 
                        ? "Select Estimated End Date" 
                        : DateFormat('MMM d, y').format(_estimatedEndDate!),
                    style: TextStyle(color: _estimatedEndDate == null ? Colors.grey[700] : Colors.black, fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, color: kPrimaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitFinalAcceptance,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAcceptColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Confirm & Send", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: kPrimaryColor, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor))]), const SizedBox(height: 16), child]),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kFieldColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: kPrimaryColor, size: 20)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500))]))]);
  }
}
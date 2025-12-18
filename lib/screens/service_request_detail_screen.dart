import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/service_request_provider.dart';

// --- Theme Constants ---
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color kAcceptColor = Color(0xFF4CAF50);
const Color kDeclineColor = Color(0xFFD32F2F);
const Color kCompleteColor = Color(0xFF2196F3);

class ServiceRequestDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceRequestDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceRequestDetailsScreen> createState() => _ServiceRequestDetailsScreenState();
}

class _ServiceRequestDetailsScreenState extends State<ServiceRequestDetailsScreen> {
  final ServiceRequestHandler _requestHandler = ServiceRequestHandler();

  bool _isLoading = true;
  bool _showInputFields = false; // Only used for initial acceptance
  
  Map<String, dynamic>? _serviceData;
  Map<String, dynamic>? _customerProfile;
  Map<String, dynamic>? _serviceDetails;

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

  Future<void> _fetchData() async {
    try {
      final data = await _requestHandler.fetchRequestDetails(widget.serviceId);
      if (mounted) {
        setState(() {
          _serviceData = data.serviceData;
          _customerProfile = data.customerProfile;
          _serviceDetails = data.serviceDetails;
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

  // --- Date Picker Logic ---
  Future<DateTime?> _pickDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: kPrimaryColor, onPrimary: Colors.white, onSurface: kPrimaryColor),
          ),
          child: child!,
        );
      },
    );
  }

  // --- Update Existing Job (Time or Completion) ---
  Future<void> _updateJobStatus({bool markCompleted = false, bool updateTime = false}) async {
    DateTime? newDate;
    
    if (updateTime) {
      newDate = await _pickDate();
      if (newDate == null) return; // User cancelled
    }

    if (markCompleted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Complete Job?"),
          content: const Text("Are you sure you want to mark this work as completed?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes, Complete")),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isLoading = true);

    try {
      await _requestHandler.updateJobProgress(
        serviceId: widget.serviceId,
        newEstimatedEnd: newDate,
        markAsCompleted: markCompleted,
      );

      // Refresh data to show new status
      await _fetchData(); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(markCompleted ? 'Job Marked as Completed!' : 'Time Updated Successfully'),
            backgroundColor: kAcceptColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // --- Initial Acceptance Logic ---
  Future<void> _submitInitialAcceptance() async {
    if (_priceController.text.isEmpty || _estimatedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Price and Estimated End Date")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _requestHandler.acceptService(
        serviceId: widget.serviceId,
        price: double.parse(_priceController.text.trim()),
        estimatedEndDate: _estimatedEndDate!.toIso8601String(),
      );
      await _fetchData(); // Refresh UI to show "In Progress" state
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleDecline() async {
    // ... (Keep existing decline logic)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Decline Job"),
        content: const Text("Are you sure? This will remove the request."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Decline", style: TextStyle(color: kDeclineColor))),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _requestHandler.declineService(widget.serviceId);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: kBackgroundColor, body: Center(child: CircularProgressIndicator(color: kPrimaryColor)));
    }

    if (_serviceData == null || _customerProfile == null) {
      return const Scaffold(body: Center(child: Text("Service not found")));
    }

    // Data Extraction
    final s = _serviceData!;
    final p = _customerProfile!;
    final details = _serviceDetails;
    
    final isAccepted = s['accepted_status'] == true;
    final isCompleted = details != null && details['completed_date'] != null;
    
    // Display Strings
    final expectedEnd = details?['expected_end'] != null 
        ? DateFormat('MMM d, y').format(DateTime.parse(details!['expected_end'])) 
        : "Not Set";

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
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
                // Customer Avatar
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: kBackgroundColor, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: p['avatar_url'] != null ? NetworkImage(p['avatar_url']) : null,
                      child: p['avatar_url'] == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text("${p['first_name']} ${p['last_name']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                const SizedBox(height: 30),

                // --- Status Banner ---
                if (isCompleted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: kAcceptColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: kAcceptColor)),
                    child: const Text("Job Completed", textAlign: TextAlign.center, style: TextStyle(color: kAcceptColor, fontWeight: FontWeight.bold, fontSize: 18)),
                  )
                else if (isAccepted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: kCompleteColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: kCompleteColor)),
                    child: const Text("Work In Progress", textAlign: TextAlign.center, style: TextStyle(color: kCompleteColor, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),

                // --- Details ---
                _buildInfoCard(
                  title: "Service Details",
                  icon: Icons.work,
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.title, "Title", s['service_title']),
                      const Divider(height: 24),
                      _buildDetailRow(Icons.location_on, "Location", s['location'] ?? "No location"),
                      if (isAccepted && details != null) ...[
                        const Divider(height: 24),
                        _buildDetailRow(Icons.calendar_today, "Est. Completion", expectedEnd),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.attach_money, "Price", "${details['price']} PKR"),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- ACTION BUTTONS LOGIC ---
                
                // Case 1: Job Completed (No Actions)
                if (isCompleted)
                  const SizedBox() 

                // Case 2: Accepted & In Progress (Update Actions)
                else if (isAccepted)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () => _updateJobStatus(updateTime: true),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kPrimaryColor, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Update Estimated Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _updateJobStatus(markCompleted: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAcceptColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Mark as Completed", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  )

                // Case 3: New Request (Accept/Decline)
                else if (!_showInputFields)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            onPressed: _handleDecline,
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: kDeclineColor, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text("Decline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDeclineColor)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _showInputFields = true),
                            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text("Accept Job", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  )
                
                // Case 4: Filling Details for Acceptance
                else 
                  _buildAcceptanceForm(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kPrimaryColor), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Finalize Agreement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          const SizedBox(height: 20),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Agreed Price", prefixText: "PKR ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: kFieldColor),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final date = await _pickDate();
              if (date != null) setState(() => _estimatedEndDate = date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(color: kFieldColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_estimatedEndDate == null ? "Select Estimated End Date" : DateFormat('MMM d, y').format(_estimatedEndDate!), style: TextStyle(color: _estimatedEndDate == null ? Colors.grey[700] : Colors.black, fontSize: 16)),
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
              onPressed: _submitInitialAcceptance,
              style: ElevatedButton.styleFrom(backgroundColor: kAcceptColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
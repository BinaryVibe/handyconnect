import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/service_provider.dart';
import '../utils/service_with_worker.dart';

const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kBackgroundColor = Color(0xFFF7F2EF);

class CustomerBookingScreen extends StatefulWidget {
  const CustomerBookingScreen({super.key});

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  final CustomerServiceHandler _serviceHandler = CustomerServiceHandler();
  
  // Get current user ID
  String get _customerId => Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<ServiceWithWorker>>(
        future: _customerId.isNotEmpty 
            ? _serviceHandler.fetchCustomerServices(_customerId)
            : Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No bookings found.", style: TextStyle(color: Colors.grey)));
          }

          final services = snapshot.data!;
          
          // --- FILTER LOGIC ---
          // 1. Active/Payment Due: Accepted by worker AND Not Paid Yet
          final activeServices = services.where((s) {
            final isAccepted = s.service.acceptedStatus == true;
            final isNotPaid = s.serviceDetails?.paidStatus == false;
            return isAccepted && isNotPaid;
          }).toList();

          // 2. History/Pending: Not accepted yet OR Already Paid
          final otherServices = services.where((s) => 
            !activeServices.contains(s)
          ).toList();

          return RefreshIndicator(
            onRefresh: () async { setState(() {}); },
            color: kPrimaryColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ACTIVE / PAYMENT DUE ---
                  if (activeServices.isNotEmpty) ...[
                    const Text(
                      "Active Jobs",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor),
                    ),
                    const SizedBox(height: 12),
                    ...activeServices.map((s) => _buildActiveCard(s)),
                    const SizedBox(height: 30),
                  ],

                  // --- HISTORY / PENDING ---
                  if (otherServices.isNotEmpty) ...[
                    const Text(
                      "History & Pending",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ...otherServices.map((s) => _buildStandardCard(s)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- ACTIVE JOB CARD (Handles Progress & Payment) ---
  Widget _buildActiveCard(ServiceWithWorker data) {
    final s = data.service;
    final workerName = data.workerName;
    final price = data.serviceDetails?.price;
    
    // CHECK: Has the worker marked it as completed?
    final isJobCompleted = data.serviceDetails?.completedDate != null;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    s.serviceTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
                  ),
                ),
                // Dynamic Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isJobCompleted ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isJobCompleted ? Colors.green.shade200 : Colors.blue.shade200
                    ),
                  ),
                  child: Text(
                    isJobCompleted ? "Payment Due" : "In Progress",
                    style: TextStyle(
                      color: isJobCompleted ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold, 
                      fontSize: 12
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              s.description ?? "No details provided.",
              style: TextStyle(color: Colors.grey[700], height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),

            // Worker & Price
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: data.workerAvatar != null ? NetworkImage(data.workerAvatar!) : null,
                  child: data.workerAvatar == null ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Worker", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(workerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Agreed Price", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      price != null ? "$price PKR" : "Pending",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- CONDITION: Show Button ONLY if Job is Completed ---
            if (isJobCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Payment Logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Processing payment for $workerName..."))
                    );
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text("Send Payment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else
              // If not completed, show a status container instead of a button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "Waiting for worker to complete job",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- STANDARD CARD (History/Pending) ---
  Widget _buildStandardCard(ServiceWithWorker data) {
    final isPending = !data.service.acceptedStatus;
    // Completed AND Paid
    final isFullyDone = data.service.acceptedStatus && data.serviceDetails?.paidStatus == true;
    
    String statusText = "Unknown";
    Color statusColor = Colors.grey;
    
    if (isPending) {
      statusText = "Pending";
      statusColor = Colors.orange;
    } else if (isFullyDone) {
      statusText = "Paid & Closed";
      statusColor = Colors.green;
    } else {
      statusText = "Cancelled"; // Default fallback
      statusColor = Colors.red;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(data.service.serviceTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(data.service.description ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/service_provider.dart';
import '../utils/service_with_worker.dart';

// Theme Constants (matching your dashboard)
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kBackgroundColor = Color(0xFFF7F2EF);

class CustomerBookingScreen extends StatefulWidget {
  const CustomerBookingScreen({super.key});

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  final CustomerServiceHandler _serviceHandler = CustomerServiceHandler();
  
  // Fetch current user ID dynamically
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
          // "In Progress": Accepted by worker, but NOT completed/paid yet
          final inProgressServices = services.where((s) {
            final isAccepted = s.service.acceptedStatus == true;
            final isNotPaid = s.serviceDetails?.paidStatus == false;
            // You might also want to check if completedDate is null, depending on your flow
            final isNotCompleted = s.serviceDetails?.completedDate == null;
            
            return isAccepted && (isNotPaid || isNotCompleted);
          }).toList();

          // "History/Pending": Not accepted yet OR already completed/paid
          final otherServices = services.where((s) => 
            !inProgressServices.contains(s)
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
                  // --- SECTION: IN PROGRESS ---
                  if (inProgressServices.isNotEmpty) ...[
                    const Text(
                      "In Progress",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor),
                    ),
                    const SizedBox(height: 12),
                    ...inProgressServices.map((s) => _buildInProgressCard(s)),
                    const SizedBox(height: 30),
                  ],

                  // --- SECTION: HISTORY / PENDING ---
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

  // --- SPECIAL CARD: IN PROGRESS ---
  Widget _buildInProgressCard(ServiceWithWorker data) {
    final s = data.service;
    final workerName = data.workerName;
    final price = data.serviceDetails?.price;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Job Name & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s.serviceTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text("In Progress", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              s.description ?? "No details provided.",
              style: TextStyle(color: Colors.grey[700], height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),

            // Worker & Price Details
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

            // --- SEND PAYMENT BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement Payment Gateway Logic (e.g., Stripe)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Initiating payment of $price PKR to $workerName..."),
                      backgroundColor: Colors.green,
                    )
                  );
                },
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text("Send Payment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STANDARD CARD (For History/Pending) ---
  Widget _buildStandardCard(ServiceWithWorker data) {
    final isPending = !data.service.acceptedStatus;
    final isCompleted = data.service.acceptedStatus && (data.serviceDetails?.completedDate != null || data.serviceDetails?.paidStatus == true);
    
    // Determine status text and color
    String statusText = "Unknown";
    Color statusColor = Colors.grey;
    
    if (isPending) {
      statusText = "Pending";
      statusColor = Colors.orange;
    } else if (isCompleted) {
      statusText = "Completed";
      statusColor = Colors.blue;
    } else {
      // Fallback for cases that might slip through filters
      statusText = "Active"; 
      statusColor = kPrimaryColor;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(data.service.serviceTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(data.service.description ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
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
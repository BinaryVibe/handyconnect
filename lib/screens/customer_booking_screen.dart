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
  
  // Track processing state to prevent double-clicks
  String? _processingPaymentId;

  String get _customerId => Supabase.instance.client.auth.currentUser?.id ?? '';

  // --- HANDLE PAYMENT & RATING FLOW ---
  Future<void> _handlePayment(String serviceId, String workerId, String workerName) async {
    setState(() => _processingPaymentId = serviceId);

    try {
      // 1. Process Payment
      await _serviceHandler.makePayment(serviceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment successful to $workerName!"), backgroundColor: Colors.green),
        );

        // 2. Show Rating Dialog IMMEDIATELY after payment success
        await _showRatingDialog(serviceId, workerId, workerName);

        // 3. Refresh UI (This moves the card to History because paid_status is now true)
        setState(() {}); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Action failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingPaymentId = null);
      }
    }
  }

  // --- RATING DIALOG (Updated) ---
  Future<void> _showRatingDialog(String serviceId, String workerId, String workerName) async {
    double _rating = 0.0; // Start at 0 to enforce selection
    final _commentController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false, // Force user to interact
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Rate $workerName", style: const TextStyle(color: kPrimaryColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Please rate the service to continue"),
                  const SizedBox(height: 20),
                  // Star Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => setDialogState(() => _rating = index + 1.0),
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                 
                ],
              ),
              actions: [
                // Skip Button Removed
                
                ElevatedButton(
                  // Disable button if rating is 0
                  onPressed: _rating == 0.0 ? null : () async {
                    try {
                      await _serviceHandler.submitReview(
                        serviceId: serviceId,
                        workerId: workerId,
                        rating: _rating,
                        comment: _commentController.text.trim(),
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review submitted!"), backgroundColor: kPrimaryColor),
                        );
                      }
                    } catch (e) {
                      print(e); // Handle error silently or show toast
                      Navigator.pop(ctx); 
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    disabledBackgroundColor: Colors.grey, // Visual cue for disabled state
                  ),
                  child: const Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
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
          // Active: Accepted AND Not Paid Yet
          final activeServices = services.where((s) {
            final isAccepted = s.service.acceptedStatus == true;
            final isNotPaid = s.serviceDetails?.paidStatus == false;
            return isAccepted && isNotPaid;
          }).toList();

          // History: Not accepted OR Already Paid
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
                  if (activeServices.isNotEmpty) ...[
                    const Text("Active Jobs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                    const SizedBox(height: 12),
                    ...activeServices.map((s) => _buildActiveCard(s)),
                    const SizedBox(height: 30),
                  ],

                  if (otherServices.isNotEmpty) ...[
                    const Text("History & Pending", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
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

  Widget _buildActiveCard(ServiceWithWorker data) {
    final s = data.service;
    final workerName = data.workerName;
    final price = data.serviceDetails?.price;
    final isJobCompleted = data.serviceDetails?.completedDate != null;
    final isProcessing = _processingPaymentId == s.id;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(s.serviceTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isJobCompleted ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isJobCompleted ? Colors.green.shade200 : Colors.blue.shade200),
                  ),
                  child: Text(
                    isJobCompleted ? "Payment Due" : "In Progress",
                    style: TextStyle(color: isJobCompleted ? Colors.green : Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(s.description ?? "No details.", style: TextStyle(color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
            const Divider(height: 24),
            Row(
              children: [
                // --- AVATAR FIX (From previous steps) ---
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (data.workerAvatar != null && data.workerAvatar!.isNotEmpty)
                      ? NetworkImage(data.workerAvatar!)
                      : null,
                  child: (data.workerAvatar == null || data.workerAvatar!.isEmpty)
                      ? const Icon(Icons.person, size: 24, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(workerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Text(
                  price != null ? "$price PKR" : "Pending",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- PAY BUTTON LOGIC ---
            if (isJobCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : () => _handlePayment(s.id, s.workerId, workerName),
                  icon: isProcessing 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.payment, color: Colors.white),
                  label: Text(
                    isProcessing ? "Processing..." : "Send Payment",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Waiting for worker completion", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(ServiceWithWorker data) {
    final isPending = !data.service.acceptedStatus;
    final isPaid = data.serviceDetails?.paidStatus == true;
    
    String statusText = isPending ? "Pending" : (isPaid ? "Paid & Closed" : "Cancelled");
    Color statusColor = isPending ? Colors.orange : (isPaid ? Colors.green : Colors.red);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(data.service.serviceTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}
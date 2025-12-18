import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/service_provider.dart';
import '../providers/worker_provider.dart';
import '../components/worker_service_card.dart'; // Make sure this file contains class 'ServiceCard'
import '../utils/customer_with_service.dart'; 
import 'service_request_detail_screen.dart'; 

const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kBackgroundColor = Color(0xFFF7F2EF);

class WorkerHistoryScreen extends StatefulWidget {
  const WorkerHistoryScreen({super.key});

  @override
  State<WorkerHistoryScreen> createState() => _WorkerHistoryScreenState();
}

class _WorkerHistoryScreenState extends State<WorkerHistoryScreen> {
  final WorkerServiceHandler _workerServiceHandler = WorkerServiceHandler();
  final WorkerHandler _workerHandler = WorkerHandler(); 
  
  String get _workerId => _workerHandler.userId ?? '';

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Job History"),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<ServiceWithCustomer>>(
        future: _workerId.isNotEmpty 
            ? _workerServiceHandler.fetchWorkerServices(_workerId)
            : Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No history found.", style: TextStyle(color: Colors.grey)));
          }

          final services = snapshot.data!;

          // --- FILTER: Only Paid & Completed Jobs ---
          final historyServices = services.where((s) {
            final isPaid = s.serviceDetails?.paidStatus == true;
            return isPaid; 
          }).toList();

          if (historyServices.isEmpty) {
            return const Center(child: Text("No completed jobs yet.", style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: kPrimaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyServices.length,
              itemBuilder: (context, index) {
                final service = historyServices[index];
                
                // --- FIXED WIDGET NAME HERE ---
                return ServiceCard( 
                  serviceWithCustomer: service,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceRequestDetailsScreen(
                          serviceId: service.service.id, 
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
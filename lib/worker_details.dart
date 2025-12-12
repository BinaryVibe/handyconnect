import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'worker_edit_page.dart';
import 'worker_model.dart';

const Color kPrimaryColor = Color(0xFF4A2E1E);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);

class WorkerDetailsPage extends StatefulWidget {
  final Worker worker;
  const WorkerDetailsPage({super.key, required this.worker});

  @override
  State<WorkerDetailsPage> createState() => _WorkerDetailsPageState();
}

class _WorkerDetailsPageState extends State<WorkerDetailsPage> {

  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Worker Details",
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: kPrimaryColor),
            onPressed: () async {
              final updatedWorker = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkerEditPage(worker: worker),
                ),
              );

              if (updatedWorker != null) {
                setState(() {
                  widget.worker.name = updatedWorker.name;
                  widget.worker.category = updatedWorker.category;
                  widget.worker.description = updatedWorker.description;
                  widget.worker.experience = updatedWorker.experience;
                  widget.worker.pricing = updatedWorker.pricing;
                  widget.worker.tools = updatedWorker.tools;
                  widget.worker.availableDates = updatedWorker.availableDates;
                });
              }
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Worker Image
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: kFieldColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(worker.image, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 20),

            // Basic Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(worker.category, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(worker.rating.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                      const Icon(Icons.star, color: Colors.amber),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(worker.description, style: const TextStyle(fontSize: 16, color: Colors.black87)),

            const SizedBox(height: 25),

            const Text("Available Dates",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),

            const SizedBox(height: 12),

            _buildCalendar(worker.availableDates),

            const SizedBox(height: 25),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(List<DateTime> dates) {
    if (dates.isEmpty) {
      return const Text("No available dates.", style: TextStyle(color: Colors.grey));
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (_, index) {
          final d = dates[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('MMM').format(d), style: const TextStyle(color: Colors.white)),
                Text(DateFormat('dd').format(d),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'worker_model.dart';

class WorkerEditPage extends StatefulWidget {
  final Worker worker;
  const WorkerEditPage({super.key, required this.worker});

  @override
  State<WorkerEditPage> createState() => _WorkerEditPageState();
}

class _WorkerEditPageState extends State<WorkerEditPage> {
  late TextEditingController nameCtrl;
  late TextEditingController catCtrl;
  late TextEditingController descCtrl;
  late TextEditingController expCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController toolsCtrl;

  List<DateTime> selectedDates = [];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.worker.name);
    catCtrl = TextEditingController(text: widget.worker.category);
    descCtrl = TextEditingController(text: widget.worker.description);
    expCtrl = TextEditingController(text: widget.worker.experience);
    priceCtrl = TextEditingController(text: widget.worker.pricing);
    toolsCtrl = TextEditingController(text: widget.worker.tools);

    selectedDates = [...widget.worker.availableDates];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Worker Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field("Name", nameCtrl),
            _field("Category", catCtrl),
            _field("Description", descCtrl),
            _field("Experience", expCtrl),
            _field("Pricing", priceCtrl),
            _field("Tools", toolsCtrl),

            const SizedBox(height: 20),
            const Text("Select Available Dates",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: DateTime.now(),
                );

                if (date != null) {
                  setState(() {
                    selectedDates.add(date);
                  });
                }
              },
              child: const Text("Add Availability"),
            ),

            Expanded(
              child: ListView(
                children: selectedDates
                    .map((d) => ListTile(
                          title: Text(DateFormat('MMM dd, yyyy').format(d)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedDates.remove(d);
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context,
                    Worker(
                      name: nameCtrl.text,
                      category: catCtrl.text,
                      rating: widget.worker.rating,
                      description: descCtrl.text,
                      experience: expCtrl.text,
                      pricing: priceCtrl.text,
                      tools: toolsCtrl.text,
                      image: widget.worker.image,
                      availableDates: selectedDates,
                    ));
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/service.dart'; // import your Service class

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Supabase.initialize(
//     url: 'https://afgvpnvqxzmosfogcysc.supabase.co',
//     anonKey: 'sb_publishable_bLKZ8iWn8-BenfJLuq0TaA_ZVgzUItK',
//   );
//   runApp(const BookServiceScreen());
// }

class BookServiceScreen extends StatefulWidget {
  final String workerId;
  final String customerId;

  const BookServiceScreen({
    required this.workerId,
    required this.customerId,
    super.key,
  });

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final newService = Service(
      id: const Uuid().v4(),
      workerId: widget.workerId,
      customerId: widget.customerId,

      serviceTitle: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      acceptedStatus: false,
      createdAt: now,
      updatedAt: now,

    );

    // TODO: send newService.toJson() to your API / Supabase backend

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pop(context, newService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Service'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Service Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a service title' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a location' : null,
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

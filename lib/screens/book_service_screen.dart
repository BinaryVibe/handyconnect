import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../models/worker.dart';

// --- Theme Constants ---
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);

class BookServiceScreen extends StatefulWidget {
  final Worker worker;

  const BookServiceScreen({super.key, required this.worker});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  // --- Controllers ---
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // --- State Variables ---
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- SUBMIT LOGIC (Push to Supabase) ---
  Future<void> _submitBooking() async {
    // 1. Validate Inputs (Removed Price/Date checks)
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and location')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 2. Get Current User ID (Customer)
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // 3. Insert into 'services' table AND return the new row
      final serviceResponse = await Supabase.instance.client
          .from('services')
          .insert({
            'worker_id': widget.worker.id,
            'customer_id': userId,
            'service_title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'location': _locationController.text.trim(),
            'accepted_status': false, // Default: Pending
            'created_at': DateTime.now().toIso8601String(),
          })
          .select() // Request the inserted row back so we can get its ID
          .single();

      final newServiceId = serviceResponse['id'];

      // 4. Insert into 'service_details' table 
      // NOTE: We are no longer sending 'price' or 'booking_date'.
      // Ensure your Database columns are Nullable or have defaults.
      await Supabase.instance.client
          .from('service_details')
          .insert({
            'service_id': newServiceId,
            'paid_status': false,
          });

      if (!mounted) return;

      // 5. Success!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking Request Sent Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Go back to the previous screen
      context.pop();

    } catch (error) {
      // 6. Error Handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking service: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Book Service",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkerProfileCard(),
                const SizedBox(height: 24),
                const Text(
                  "Service Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField("Service Title", _titleController),
                const SizedBox(height: 12),
                _buildTextField("Description", _descriptionController, maxLines: 3),
                const SizedBox(height: 12),
                _buildTextField("Location", _locationController, icon: Icons.location_on_outlined),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildWorkerProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFEA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(widget.worker.avatarUrl ?? ''),
            backgroundColor: Colors.grey[300],
            child: widget.worker.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.worker.firstName} ${widget.worker.lastName}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                Text(
                  widget.worker.profession,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.worker.avgRating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1,
      TextInputType inputType = TextInputType.text,
      String? prefix,
      IconData? icon}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: kFieldColor,
        prefixText: prefix,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600], size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Confirm Booking",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
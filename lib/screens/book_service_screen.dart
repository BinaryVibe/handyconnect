import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  // --- State Variables ---
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- Date & Time Pickers ---
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // --- SUBMIT LOGIC (Push to Supabase) ---
  Future<void> _submitBooking() async {
    // 1. Validate Inputs
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 2. Get Current User ID (Customer)
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // 3. Combine Date and Time
      final DateTime finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // 4. Insert into 'services' table AND return the new row
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

      // 5. Insert into 'service_details' table using the new ID
      await Supabase.instance.client
          .from('service_details')
          .insert({
            'service_id': newServiceId,
            'price': double.parse(_priceController.text.trim()),
            'booking_date': finalDateTime.toIso8601String(),
            'paid_status': false,
          });

      if (!mounted) return;

      // 6. Success!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking Request Sent Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Go back to the previous screen
      context.pop();

    } catch (error) {
      // 7. Error Handling
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
      // --- UPDATE: Centered Layout for Desktop ---
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Limit width on desktop
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
                _buildTextField(
                  "Your Offer (Price)",
                  _priceController,
                  inputType: TextInputType.number,
                  prefix: "\$ ", 
                ),
                const SizedBox(height: 12),
                _buildDateTimeRow(),
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

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Booking Date",
                  style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryColor, fontSize: 12)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: kFieldColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? "Select Date"
                            : DateFormat('MMM d, y').format(_selectedDate!),
                        style: TextStyle(
                            color: _selectedDate == null ? Colors.grey[500] : Colors.black87),
                      ),
                      Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Start Time",
                  style: TextStyle(fontWeight: FontWeight.w600, color: kPrimaryColor, fontSize: 12)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: kFieldColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? "Select Time"
                            : _selectedTime!.format(context),
                        style: TextStyle(
                            color: _selectedTime == null ? Colors.grey[500] : Colors.black87),
                      ),
                      Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
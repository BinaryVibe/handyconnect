import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Theme Constants ---
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color tagsBgColor = Color(0xFFBFC882);

class WorkerProfileScreen extends StatefulWidget {
  final String workerId;

  const WorkerProfileScreen({super.key, required this.workerId});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // --- Controllers ---
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _professionController = TextEditingController();
  final _skillController = TextEditingController(); 

  // --- State Variables ---
  String? _email;
  String? _avatarUrl;
  List<String> _skills = [];
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  // --- 1. FETCH DATA ---
  Future<void> _loadProfileData() async {
    try {
      final client = Supabase.instance.client;

      final profileData = await client
          .from('profiles')
          .select()
          .eq('id', widget.workerId)
          .single();

      final workerData = await client
          .from('workers')
          .select()
          .eq('id', widget.workerId)
          .single();

      setState(() {
        _firstNameController.text = profileData['first_name'] ?? '';
        _lastNameController.text = profileData['last_name'] ?? '';
        _phoneController.text = profileData['phone_number'] ?? '';
        _email = profileData['email'] ?? '';
        _avatarUrl = profileData['avatar_url'];

        _professionController.text = workerData['profession'] ?? '';
        _isAvailable = workerData['availability'] ?? false;

        if (workerData['skills'] != null) {
          _skills = List<String>.from(workerData['skills']);
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 2. UPDATE DATA ---
  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      final client = Supabase.instance.client;

      await client.from('profiles').update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.workerId);

      await client.from('workers').update({
        'profession': _professionController.text.trim(),
        'availability': _isAvailable,
        'skills': _skills, 
      }).eq('id', widget.workerId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- Helpers ---
  void _addSkill() {
    final newSkill = _skillController.text.trim();
    if (newSkill.isNotEmpty && !_skills.contains(newSkill)) {
      setState(() {
        _skills.add(newSkill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  // --- MAIN UI ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    // UPDATED: Center + ConstrainedBox creates the margins on desktop
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000), // Limits width on big screens
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine layout based on the constrained width
            final isMobile = constraints.maxWidth < 800;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  if (isMobile) ...[
                    // --- Mobile: Stack Vertical ---
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 16),
                    _buildProfessionalInfoCard(),
                  ] else ...[
                    // --- Desktop: Side by Side ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPersonalInfoCard()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildProfessionalInfoCard()),
                      ],
                    ),
                  ],

                  const SizedBox(height: 30),
                  _buildSaveButton(),
                  const SizedBox(height: 40), 
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE5D5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: kPrimaryColor,
            backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
            child: _avatarUrl == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            "${_firstNameController.text} ${_lastNameController.text}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _professionController.text.isNotEmpty
                ? _professionController.text
                : "No profession set",
            style: TextStyle(fontSize: 16, color: Colors.brown[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildCard(
      title: "Personal Information",
      child: Column(
        children: [
          _buildTextField("First Name", _firstNameController),
          const SizedBox(height: 16),
          _buildTextField("Last Name", _lastNameController),
          const SizedBox(height: 16),
          _buildTextField("Email", TextEditingController(text: _email),
              isReadOnly: true),
          const SizedBox(height: 16),
          _buildTextField("Phone Number", _phoneController,
              inputType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoCard() {
    return _buildCard(
      title: "Professional Details",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Profession", _professionController),
          const SizedBox(height: 24),

          const Text("Skills",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: kPrimaryColor)),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) {
              return Chip(
                label: Text(skill),
                backgroundColor: tagsBgColor.withOpacity(0.5),
                deleteIcon: const Icon(Icons.close, size: 16, color: Colors.black54),
                onDeleted: () => _removeSkill(skill),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      hintText: "Add a skill...",
                      filled: true,
                      fillColor: kFieldColor,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addSkill,
                icon: const Icon(Icons.add_circle,
                    color: kPrimaryColor, size: 32),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Availability",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor),
            ),
            subtitle: Text(
              _isAvailable
                  ? "You are listed as Available"
                  : "You are listed as Unavailable",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            value: _isAvailable,
            activeColor: kPrimaryColor,
            onChanged: (val) => setState(() => _isAvailable = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Save Changes",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isReadOnly = false,
      TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: inputType,
          style: TextStyle(
              color: isReadOnly ? Colors.grey[600] : kPrimaryColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? Colors.grey[200] : kFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
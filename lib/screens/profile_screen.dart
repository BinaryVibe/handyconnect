import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// --- Theme Constants ---
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color tagsBgColor = Color(0xFFBFC882);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- State Variables ---
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;
  bool _isWorker = false;
  String? _userId;

  // --- Common Controllers ---
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // --- Worker Specific Controllers/Vars ---
  final _professionController = TextEditingController();
  final _skillController = TextEditingController();
  List<String> _skills = [];
  bool _isAvailable = false;

  // --- Display Vars ---
  String? _email;
  String? _avatarUrl;
  DateTime? _dateJoined;
  final ImagePicker _picker = ImagePicker();

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

  // --- 1. LOAD DATA ---
  Future<void> _loadProfileData() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        context.go('/login');
        return;
      }
      _userId = user.id;

      // A. Fetch Basic Profile
      final profileData = await client
          .from('profiles')
          .select()
          .eq('id', _userId!)
          .single();

      final String role = profileData['role'] ?? 'customer';
      _isWorker = (role == 'worker');

      if (mounted) {
        setState(() {
          _firstNameController.text = profileData['first_name'] ?? '';
          _lastNameController.text = profileData['last_name'] ?? '';
          _phoneController.text = profileData['phone_number'] ?? '';
          _email = profileData['email'] ?? '';
          // Add timestamp to force image refresh
          _avatarUrl = profileData['avatar_url'] != null 
              ? '${profileData['avatar_url']}?t=${DateTime.now().millisecondsSinceEpoch}' 
              : null;
        });
      }

      // B. Conditional Fetch based on Role
      if (_isWorker) {
        final workerData = await client
            .from('workers')
            .select()
            .eq('id', _userId!)
            .single();

        if (mounted) {
          setState(() {
            _professionController.text = workerData['profession'] ?? '';
            _isAvailable = workerData['availability'] ?? false;
            if (workerData['skills'] != null) {
              _skills = List<String>.from(workerData['skills']);
            }
          });
        }
      } else {
        final customerData = await client
            .from('customers')
            .select('date_joined')
            .eq('id', _userId!)
            .maybeSingle();

        if (mounted && customerData != null) {
          setState(() {
            _dateJoined = DateTime.tryParse(customerData['date_joined'] ?? '');
          });
        }
      }

      if (mounted) setState(() => _isLoading = false);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 2. IMAGE UPLOAD (UPDATED BUCKET NAME) ---
  Future<void> _uploadProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
      );
      if (image == null) return;

      setState(() => _isUploading = true);

      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '$_userId/profile.$fileExt';

      // CHANGE HERE: 'avatars' instead of 'profile_pics'
      await Supabase.instance.client.storage
          .from('avatars') 
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: image.mimeType ?? 'image/jpeg',
            ),
          );

      // CHANGE HERE: 'avatars' instead of 'profile_pics'
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
      
      final imageUrlWithTimestamp = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', _userId!);

      setState(() {
        _avatarUrl = imageUrlWithTimestamp;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  // --- 3. SAVE DATA ---
  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final client = Supabase.instance.client;

      await client.from('profiles').update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _userId!);

      if (_isWorker) {
        await client.from('workers').update({
          'profession': _professionController.text.trim(),
          'availability': _isAvailable,
          'skills': _skills,
        }).eq('id', _userId!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- Helper Methods ---
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
    setState(() => _skills.remove(skill));
  }

  // --- MAIN UI ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _isWorker ? 1000 : 600),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  if (_isWorker) ...[
                    if (isMobile) ...[
                      _buildPersonalInfoCard(),
                      const SizedBox(height: 16),
                      _buildWorkerDetailsCard(),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPersonalInfoCard()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildWorkerDetailsCard()),
                        ],
                      ),
                    ]
                  ] else ...[
                    _buildPersonalInfoCard(),
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
          Stack(
            children: [
              _isUploading 
                  ? const CircleAvatar(radius: 50, backgroundColor: Colors.white, child: CircularProgressIndicator(color: kPrimaryColor))
                  : CircleAvatar(
                      radius: 50,
                      backgroundColor: kPrimaryColor,
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                    ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: _uploadProfilePicture,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "${_firstNameController.text} ${_lastNameController.text}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
          const SizedBox(height: 4),
          
          if (_isWorker)
             Text(_professionController.text.isNotEmpty ? _professionController.text : "No profession set", style: TextStyle(fontSize: 16, color: Colors.brown[600]))
          else if (_dateJoined != null)
             Text("Customer since ${DateFormat('MMMM yyyy').format(_dateJoined!)}", style: TextStyle(fontSize: 14, color: Colors.brown[600])),
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
          _buildTextField("Email", TextEditingController(text: _email), isReadOnly: true),
          const SizedBox(height: 16),
          _buildTextField("Phone Number", _phoneController, inputType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildWorkerDetailsCard() {
    return _buildCard(
      title: "Professional Details",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Profession", _professionController),
          const SizedBox(height: 24),
          const Text("Skills", style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _skills.map((skill) => Chip(
              label: Text(skill),
              backgroundColor: tagsBgColor.withOpacity(0.5),
              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.black54),
              onDeleted: () => _removeSkill(skill),
            )).toList(),
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
                      hintText: "Add a skill...", filled: true, fillColor: kFieldColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _addSkill, icon: const Icon(Icons.add_circle, color: kPrimaryColor, size: 32)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Availability", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor)),
            subtitle: Text(_isAvailable ? "You are listed as Available" : "You are listed as Unavailable", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isReadOnly = false, TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: inputType,
          style: TextStyle(color: isReadOnly ? Colors.grey[600] : kPrimaryColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? Colors.grey[200] : kFieldColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
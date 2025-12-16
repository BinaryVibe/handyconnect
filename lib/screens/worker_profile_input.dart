import 'dart:typed_data'; // Required for Web/Mobile bytes
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:handyconnect/providers/user_provider.dart';
import 'package:handyconnect/providers/worker_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for Storage

// --- WORKER PROFILE DETAILS SCREEN ---

final Color primaryBrown = const Color(0xFF4E342E);
final Color cardBackground = const Color(0xFFD7CCC8);
final Color scaffoldBackground = const Color(0xFFFAFAFA);

class WorkerProfileDetailsScreen extends StatefulWidget {
  const WorkerProfileDetailsScreen({super.key});

  @override
  _WorkerProfileDetailsScreenState createState() => _WorkerProfileDetailsScreenState();
}

class _WorkerProfileDetailsScreenState extends State<WorkerProfileDetailsScreen> {
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();
  final List<String> _skills = [];
  final UserHandler _userSupabaseService = UserHandler();
  final WorkerHandler _workerSupabaseService = WorkerHandler();

  // --- CHANGED: Use Bytes for Cross-Platform (Web/Mobile) ---
  Uint8List? _imageBytes;
  XFile? _pickedFile; 
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // Loading state for upload

  @override
  void dispose() {
    _professionController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final String skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _deleteSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  // --- UPDATED: Universal Image Picker ---
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        // Read as bytes immediately (works on Web and Mobile)
        final Uint8List bytes = await pickedFile.readAsBytes();
        
        setState(() {
          _pickedFile = pickedFile;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // --- UPDATED: Upload to Bucket & Save URL ---
  Future<void> _saveProfile() async {
    // 1. Validation
    if (_imageBytes == null || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture first!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Get User ID
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "User not authenticated";
      final String userId = user.id;

      // 3. Prepare File Path
      final String fileExt = _pickedFile!.name.split('.').last;
      final String filePath = '$userId/profile.$fileExt'; // e.g., "user123/profile.jpg"

      // 4. Upload to Supabase Storage ('avatars' bucket)
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            _imageBytes!,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExt', // Important for Web
            ),
          );

      // 5. Get Public URL
      final String imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // 6. Save URL to Database using your existing Services
      // passing the 'imageUrl' instead of local path
      await _userSupabaseService.setAvatarUrl(imageUrl); 

      Map<String, dynamic> workerData = {
        'profession': _professionController.text,
        'skills': _skills,
        // If your worker table also needs the image, add it here:
        // 'image_url': imageUrl 
      };

      await _workerSupabaseService.insertWorker(workerData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Saved Successfully!'), backgroundColor: Colors.green),
        );
        context.go('/w-dashboard');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        backgroundColor: scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          "Fill Your Profile",
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Profile Picture Section ---
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cardBackground.withOpacity(0.5),
                        border: Border.all(color: primaryBrown, width: 2),
                        // --- UPDATED: Use MemoryImage for Bytes ---
                        image: _imageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_imageBytes!), 
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageBytes == null
                          ? Icon(Icons.person, size: 60, color: primaryBrown.withOpacity(0.5))
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryBrown,
                        shape: BoxShape.circle,
                        border: Border.all(color: scaffoldBackground, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Profession Field ---
              _buildTextField(
                controller: _professionController,
                label: "Profession (e.g., Plumber)",
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 30),

              // --- Skills Section ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Skills",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _skillInputController,
                      label: "Add a skill",
                      icon: Icons.handyman_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: const Text("Add"),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _skills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      labelStyle: TextStyle(color: primaryBrown),
                      backgroundColor: cardBackground.withOpacity(0.5),
                      deleteIcon: Icon(Icons.cancel, size: 18, color: primaryBrown),
                      onDeleted: () => _deleteSkill(skill),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: primaryBrown.withOpacity(0.5)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),

              // --- Save Profile Button ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile, // Disable while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        "Save Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: primaryBrown),
      cursorColor: primaryBrown,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryBrown.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: primaryBrown),
        filled: true,
        fillColor: cardBackground.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryBrown.withOpacity(0.5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryBrown, width: 2),
        ),
      ),
    );
  }
}
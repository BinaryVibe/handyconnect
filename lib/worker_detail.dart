import 'dart:io'; // Required to handle file system images
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

// --- MAIN ENTRY POINT ---
void main() {
  runApp(const ServiceApp());
}

class ServiceApp extends StatelessWidget {
  const ServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Service Hub',
      theme: ThemeData(
        primaryColor: const Color(0xFF4E342E),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        useMaterial3: true,
      ),
      home: const WorkerProfileDetailsScreen(),
    );
  }
}

// --- WORKER PROFILE DETAILS SCREEN ---

final Color primaryBrown = const Color(0xFF4E342E);
final Color cardBackground = const Color(0xFFD7CCC8);
final Color scaffoldBackground = const Color(0xFFFAFAFA);

class WorkerProfileDetailsScreen extends StatefulWidget {
  const WorkerProfileDetailsScreen({Key? key}) : super(key: key);

  @override
  _WorkerProfileDetailsScreenState createState() => _WorkerProfileDetailsScreenState();
}

class _WorkerProfileDetailsScreenState extends State<WorkerProfileDetailsScreen> {
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();
  final List<String> _skills = [];

  // Variable to store the actual file picked from device
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

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

  // --- NEW: Actual Function to Pick Image ---
  Future<void> _pickImage() async {
    try {
      // Pick an image from the gallery
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _saveProfile() {
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture first!')),
      );
      return;
    }
    
    print('Profession: ${_professionController.text}');
    print('Skills: $_skills');
    print('Image Path: ${_profileImage!.path}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Saved Successfully!')),
    );
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
                        // --- UPDATED: Display local file if selected ---
                        image: _profileImage != null
                            ? DecorationImage(
                                image: FileImage(_profileImage!), 
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      // Show person icon if no image is selected
                      child: _profileImage == null
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
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
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
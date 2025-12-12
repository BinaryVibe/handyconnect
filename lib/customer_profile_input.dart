import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// --- Theme Colors ---
final Color primaryBrown = const Color(0xFF4E342E);
final Color cardBackground = const Color(0xFFD7CCC8);
final Color scaffoldBackground = const Color(0xFFFAFAFA);

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({Key? key}) : super(key: key);

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _saveProfile() {
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a profile picture to continue.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // TODO: Upload image to Supabase storage here
    print("Customer Profile Image: ${_profileImage!.path}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Setup Complete!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate to Home Screen
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerHomeScreen()));
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Complete Profile",
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              
              Text(
                "Add a Photo",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Add a profile picture so providers can recognize you.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: primaryBrown.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // --- Circular Image Picker ---
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cardBackground.withOpacity(0.4),
                        border: Border.all(color: primaryBrown, width: 3),
                        image: _profileImage != null
                            ? DecorationImage(
                                image: FileImage(_profileImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 80,
                              color: primaryBrown.withOpacity(0.4),
                            )
                          : null,
                    ),
                    // Camera Icon Badge
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryBrown,
                        shape: BoxShape.circle,
                        border: Border.all(color: scaffoldBackground, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // --- Continue Button ---
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
                    elevation: 5,
                    shadowColor: primaryBrown.withOpacity(0.4),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
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
    // TODO: Upload logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Setup Complete!'), 
        backgroundColor: Colors.green
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get total screen width using MediaQuery
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // 2. Define a threshold for "Mobile" vs "Desktop/Web"
    final bool isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        backgroundColor: scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Complete Profile",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        // 3. ConstrainedBox forces the content to never exceed 600px width.
        //    On wide screens, this creates the "gaps" on the sides automatically.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            // Optional: Add a shadow/card effect ONLY on wide screens to make it pop
            decoration: isWideScreen
                ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  )
                : null,
            // Add padding inside the container
            padding: const EdgeInsets.all(32.0),
            // Ensure full height on mobile, or wrap content on desktop
            height: isWideScreen ? null : double.infinity,
            
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrink wrap on desktop
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // For mobile, we might want some top spacing
                  if (!isWideScreen) const SizedBox(height: 40),

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
                          width: 180,
                          height: 180,
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
                                  size: 90,
                                  color: primaryBrown.withOpacity(0.4),
                                )
                              : null,
                        ),
                        // Camera Badge
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryBrown,
                            shape: BoxShape.circle,
                            border: Border.all(color: scaffoldBackground, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

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
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom spacing for mobile scrolling
                  if (!isWideScreen) const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
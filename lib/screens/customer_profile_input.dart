import 'dart:typed_data'; // Bytes handle karne ke liye
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:handyconnect/providers/customer_provider.dart';
import 'package:handyconnect/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Theme Colors ---
final Color primaryBrown = const Color(0xFF4E342E);
final Color cardBackground = const Color(0xFFD7CCC8);
final Color scaffoldBackground = const Color(0xFFFAFAFA);

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  // Change 1: Hum 'File' nahi, balki 'Bytes' store karenge (Works on Web & Mobile)
  Uint8List? _imageBytes;
  XFile? _pickedFile; // Metadata (name/ext) ke liye

  final CustomerHandler _customerHandler = CustomerHandler();
  final UserHandler _userHandler = UserHandler();

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        // Change 2: Read file as bytes immediately
        final Uint8List bytes = await pickedFile.readAsBytes();

        setState(() {
          _pickedFile = pickedFile;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (_imageBytes == null || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a profile picture to continue.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "User not logged in!";

      final String userId = user.id;

      // Get file extension from the picked file name
      final String fileExt = _pickedFile!.name.split('.').last;
      final String filePath = '$userId/profile_pic.$fileExt';

      await _userHandler.uploadAvatarAndSaveUrl(
        imageBytes: _imageBytes!,
        filePath: filePath,
        fileExt: fileExt,
      );

      // NOTE: Keep the Map empty. date_joined will be set
      // to the current time by default in the database
      await _customerHandler.insertCustomer({});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Setup Complete!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to next screen logic here...
        context.go('/c-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: $e'),
            backgroundColor: Colors.red,
          ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            decoration: isWideScreen
                ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  )
                : null,
            padding: const EdgeInsets.all(32.0),
            height: isWideScreen ? null : double.infinity,

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                      color: primaryBrown.withValues(alpha: 0.7),
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
                            color: cardBackground.withValues(alpha: 0.4),
                            border: Border.all(color: primaryBrown, width: 3),
                            // Change 4: Display using Image.memory (Universal)
                            image: _imageBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(_imageBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imageBytes == null
                              ? Icon(
                                  Icons.person,
                                  size: 90,
                                  color: primaryBrown.withValues(alpha: 0.4),
                                )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryBrown,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scaffoldBackground,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 28,
                          ),
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
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

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

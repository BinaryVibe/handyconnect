import 'package:flutter/material.dart';
import 'worker_profile_input.dart';
import 'customer_profile_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/providers/user_provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // Variable to track selected role
  String? selectedRole; // Values: 'customer', 'worker'
  
  // Assuming UserSupabaseService is defined in your providers
  final UserSupabaseService _supabaseService = UserSupabaseService();

  // Define Theme Colors based on your "Coffee" aesthetic
  final Color primaryBrown = const Color(0xFF4E342E); // Dark Brown text/buttons
  final Color cardBackground = const Color(0xFFD7CCC8); // Light Beige/Tan for cards
  final Color scaffoldBackground = const Color(0xFFFAFAFA); // Off-white background
  // Darker background for wide screens to make the white card pop
  final Color wideScaffoldBackground = const Color(0xFFEFEBE9);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we are on a wide screen (Tablet/Desktop)
        final bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          // Use a slightly darker background on wide screens for contrast
          backgroundColor: isWideScreen ? wideScaffoldBackground : scaffoldBackground,
          body: isWideScreen 
              ? _buildWideLayout() 
              : _buildMobileLayout(),
        );
      },
    );
  }

  // --- 1. Mobile Layout (< 600px) ---
  Widget _buildMobileLayout() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: _buildMainContent(isWide: false),
      ),
    );
  }

  // --- 2. Wide Layout (> 600px) ---
  Widget _buildWideLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            // We pass isWide: true to handle specific spacing inside
            child: _buildMainContent(isWide: true),
          ),
        ),
      ),
    );
  }

  // --- 3. Shared Content Widget ---
  Widget _buildMainContent({required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isWide ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Back Button
        IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),

        const SizedBox(height: 20),

        // Title Text
        Text(
          "Choose Your Role",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryBrown,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 40),

        // Customer Option Card
        _buildRoleCard(
          roleValue: 'customer',
          title: "I need a service\n(Customer)",
          subtitle: "Find reliable professionals for your needs.",
          icon: Icons.person_search_outlined,
        ),

        const SizedBox(height: 20),

        // Provider Option Card
        _buildRoleCard(
          roleValue: 'worker',
          title: "I am a provider\n(Worker)",
          subtitle: "Offer your skills and find new customers.",
          icon: Icons.handyman_outlined,
        ),

        // Spacer logic: 
        // On Mobile, we use Spacer() to push the button to the bottom of the screen.
        // On Wide screens, we just want a fixed gap because the card wraps the content.
        if (!isWide) const Spacer() else const SizedBox(height: 40),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: selectedRole == null
                ? null // Disable button if nothing selected
                : () {
                    if (selectedRole == 'customer') {
                      _supabaseService.setUserRole(selectedRole!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CustomerProfileScreen()),
                      );
                    } else if (selectedRole == 'worker') {
                      _supabaseService.setUserRole(selectedRole!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WorkerProfileDetailsScreen()),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBrown,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Continue",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        
        // Extra bottom padding for mobile only
        if (!isWide) const SizedBox(height: 20),
      ],
    );
  }

  // --- Helper Widget for the Cards ---
  Widget _buildRoleCard({
    required String roleValue,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isSelected = selectedRole == roleValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = roleValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBrown : primaryBrown.withValues(alpha: 0.5),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon Circle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryBrown, width: 2),
                color: Colors.transparent,
              ),
              child: Icon(icon, size: 32, color: primaryBrown),
            ),
            const SizedBox(width: 20),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: primaryBrown.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark if selected
            if (isSelected)
              Icon(Icons.check_circle, color: primaryBrown, size: 24),
          ],
        ),
      ),
    );
  }
}
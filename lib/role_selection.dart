import 'package:flutter/material.dart';
import 'worker_profile_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/providers/user_provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Service App',
//       theme: ThemeData(
//         // Setting the primary swatch to match your brown theme
//         primarySwatch: Colors.brown,
//         useMaterial3: true,
//       ),
//       home: const RoleSelectionScreen(),
//     );
//   }
// }

// --- PASTE THE PREVIOUS CODE BELOW THIS LINE ---

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // Variable to track selected role
  String? selectedRole; // Values: 'customer', 'provider'
  final UserSupabaseService _supabaseService = UserSupabaseService();

  // Define Theme Colors based on your "Coffee" aesthetic
  final Color primaryBrown = const Color(0xFF4E342E); // Dark Brown text/buttons
  final Color cardBackground = const Color(
    0xFFD7CCC8,
  ); // Light Beige/Tan for cards
  final Color scaffoldBackground = const Color(
    0xFFFAFAFA,
  ); // Off-white background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Back Button
              IconButton(
                icon: Icon(Icons.arrow_back, color: primaryBrown),
                onPressed: () {
                  // This handles the back button.
                  // If there is no previous screen, it might not do anything in a test run.
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),

              const SizedBox(height: 20),

              // 2. Title Text
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

              // 3. Customer Option Card
              _buildRoleCard(
                roleValue: 'customer',
                title: "I need a service\n(Customer)",
                subtitle: "Find reliable professionals for your needs.",
                icon: Icons.person_search_outlined,
              ),

              const SizedBox(height: 20),

              // 4. Provider Option Card
              _buildRoleCard(
                roleValue: 'worker',
                title: "I am a provider\n(Worker)",
                subtitle: "Offer your skills and find new customers.",
                icon: Icons.handyman_outlined,
              ),

              const Spacer(),

              // 5. Continue Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null // Disable button if nothing selected
                      : () {

                          // UNCOMMENT THIS WHEN YOU HAVE YOUR NEXT SCREENS:
                          if (selectedRole == 'worker') {
                            _supabaseService.setUserRole(selectedRole!);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WorkerProfileDetailsScreen(),
                              ),
                            );
                          } else if (selectedRole == 'customer') {
                            // TODO: Add Customer Screen logic here later
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Customer flow coming soon!"),
                              ),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  

  // Helper Widget for the Cards
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

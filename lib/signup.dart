import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'role_selection.dart';

// NEW THEME COLORS
const Color kPrimaryColor = Color(0xFF4A2E1E);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fName = TextEditingController();
  final TextEditingController lName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController confirm = TextEditingController();

  final _supabase = Supabase.instance.client;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              children: [
                _roundedField(
                  controller: fName,
                  hint: "First Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),

                _roundedField(
                  controller: lName,
                  hint: "Last Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                _roundedField(
                  controller: email,
                  hint: "Email Address",
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),

                _roundedField(
                  controller: phone,
                  hint: "Phone Number",
                  icon: Icons.phone,
                ),
                const SizedBox(height: 20),

                _roundedField(
                  controller: pass,
                  hint: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 20),

                _roundedField(
                  controller: confirm,
                  hint: "Confirm Password",
                  icon: Icons.lock,
                  isPassword: true,
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Already have an account? Log In",
                    style: TextStyle(
                      color: kPrimaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),

          if (loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kFieldColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kPrimaryColor.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // -------------------------------
  // 🔥 SUPABASE SIGN-UP FUNCTION
  // -------------------------------
  Future<void> _signUp() async {
    if (fName.text.isEmpty ||
        lName.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty ||
        pass.text.isEmpty ||
        confirm.text.isEmpty) {
      _showError("Please fill all fields.");
      return;
    }

    if (pass.text != confirm.text) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => loading = true);

    try {
      final response = await _supabase.auth.signUp(
        email: email.text.trim(),
        password: pass.text.trim(),
        data: {
          "first_name": fName.text.trim(),
          "last_name": lName.text.trim(),
          "phone": phone.text.trim(),
        },
      );

      if (!mounted) return;

      // --- CHANGE IS HERE ---
      // Navigate to Role Selection instead of Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
      
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("An unexpected error occurred.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
}

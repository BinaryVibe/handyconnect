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
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: const Text(
          "Sign Up",
          style: TextStyle(color: kFieldColor, fontSize: 30),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // NOTE: Without Expanded widgets the code will throw an exception.
                        Expanded(
                          child: _buildRoundedInputField(
                            controller: fName,
                            hintText: "First Name",
                            icon: Icons.person,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRoundedInputField(
                            controller: lName,
                            hintText: "Last Name",
                            icon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    _buildRoundedInputField(
                      controller: email,
                      hintText: "Email Address",
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 25),

                    _buildRoundedInputField(
                      controller: phone,
                      hintText: "Phone Number",
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 25),

                    _buildRoundedInputField(
                      controller: pass,
                      hintText: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 25),

                    _buildRoundedInputField(
                      controller: confirm,
                      hintText: "Confirm Password",
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to Sign Up Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: kSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (loading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
                    child: const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Icon(icon, color: kPrimaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
          ),
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
      await _supabase.auth.signUp(
        email: email.text.trim(),
        password: pass.text.trim(),
        data: {
          "first_name": fName.text.trim(),
          "last_name": lName.text.trim(),
          "phone_number": phone.text.trim(),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}
